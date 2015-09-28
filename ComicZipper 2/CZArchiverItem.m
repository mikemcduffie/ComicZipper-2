//
//  CZArchive.m
//  ComicZipper 2
//
//  Created 15/07/14.
//  Copyright (c) 2015 Ardalan Samimi. All rights reserved.
//

#import "CZArchiverItem.h"
#import "Finder.h"

// Constants for the zip
#define CZ_ZIP_RETURN_CODE_OK 0

static NSString *const kCZRegExPattern = @"\\s([0-9]+$)";
static NSString *const kCZRegExTemplate = @" #$1";
static NSString *const kCZLaunchPath = @"/bin/bash";

@interface CZArchiverItem ()

@property (nonatomic) NSTask *task;
@property (nonatomic, copy) NSString *commandLine;
@property (nonatomic, readonly) NSArray *returnCodes;
@property (nonatomic, setter = setRunning:) BOOL isRunning;
@property (nonatomic, copy) NSString *folderName, *folderPath, *parentFolder, *archivePath;
@property (nonatomic, copy) NSURL *fileURL;
@property (nonatomic) double sizeCompressed;
@property (nonatomic) int deleteCount, formatStyle;

+ (NSArray *)readableTypesForPasteboard:(NSPasteboard *)pasteboard;
+ (NSPasteboardReadingOptions)readingOptionsForType:(NSString *)type
                                         pasteboard:(NSPasteboard *)pasteboard;
- (id)initWithPasteboardPropertyList:(id)propertyList
                              ofType:(NSString *)type;
- (void)setUpPath:(NSURL *)url;
- (void)receivedData:(NSNotification *)notification;
- (void)receivedError:(NSNotification *)notification;
- (void)taskTerminated:(NSNotification *)notification;
- (void)setReturnCodes;

@end

@implementation CZArchiverItem

- (NSString *)description {
    return [self folderName];
}

- (NSString *)path {
    if ([self isArchived]) {
        return [self archivePath];
    } else {
        return [self folderPath];
    }

}

- (NSURL *)fileURL {
    if ([self isArchived]) {
        return [NSURL fileURLWithPath:[self archivePath]];
    } else {
        return _fileURL;
    }
}

#pragma mark DELEGATE METHOD

// Delete the directory
// of the item.
- (void)removeDirectory {
    if (![self isRunning] && ![[self task] isRunning]) {
        __unused NSInteger didDelete = [[NSWorkspace sharedWorkspace] performFileOperation:NSWorkspaceRecycleOperation
                                                                source:[self parentFolder]
                                                           destination:@""
                                                                 files:@[ [self folderName] ]
                                                                   tag:nil];
    }
    // Check so that the file has really
    // been deleted. Otherwise add a timer
    // to run the method again in 5 secs.
    if ([[NSFileManager defaultManager] fileExistsAtPath:[self path]]) {
        if ([self deleteCount] < 6) {
            self.deleteCount++;
            dispatch_async(dispatch_get_main_queue(), ^{
                NSTimer *rerunTimer = [NSTimer scheduledTimerWithTimeInterval:2.0
                                                                       target:self
                                                                     selector:@selector(removeDirectory)
                                                                     userInfo:nil
                                                                      repeats:NO];
                [[NSRunLoop currentRunLoop] addTimer:rerunTimer
                                             forMode:NSRunLoopCommonModes];
            });
        } else {
            [NSException raise:@"Error" format:@"Delete folder timed out"];
        }
    } else {
        self.deleteCount = 0;
        [[self delegate] archiverDidRemoveDirectory:self];
    }
}

# pragma mark PASTEBOARD DELEGATE METHODS

// Returns an array of data types as UTI strings that the
// receiver can read from the pasteboard and be initialized from.
+ (NSArray *)readableTypesForPasteboard:(NSPasteboard *)pasteboard {
    //return [NSArray arrayWithObject:(id)kUTTypeFolder]; THIS DOES NOT WORK!
    return [NSArray arrayWithObjects:(id)kUTTypeURL, nil];
}

+ (NSPasteboardReadingOptions)readingOptionsForType:(NSString *)type pasteboard:(NSPasteboard *)pasteboard {
    return NSPasteboardReadingAsString;
}

#pragma mark INITIALIZE

// The code below is a modified sample from Apple, designed to
// check if the dragover object is a folder (container). Other
// types will not create an instance of CZArchive.
- (id)initWithPasteboardPropertyList:(id)propertyList ofType:(NSString *)type {
    // Check if an NSURL can be created from the type
    if (UTTypeConformsTo((__bridge CFStringRef)type, kUTTypeURL)) {
        // Create a URL to initialize our properties
        // and check to see if the object is a folder.
        NSURL *url = [[NSURL alloc] initWithPasteboardPropertyList:propertyList ofType:type];
        NSNumber *value;

        if ([url getResourceValue:&value forKey:NSURLIsDirectoryKey error:NULL] && ![value boolValue]) {
            return nil;
        }
        
        // Set up the paths
        [self setUpPath:url];
    }
    
    [self setReturnCodes];
    self = [super init];
    return self;
}

- (instancetype)initWithURL:(NSURL *)url {
    self = [super init];
    if (self) {
        [self setUpPath:url];
        [self setReturnCodes];
    }
    return self;
}

// If the app starts with a selection then this here method is what will
// run and not the drop initializer.
- (instancetype)initWithSelection:(FinderFolder *)folder {
    self = [super init];
    if (self) {
        [self setUpPathsForFinderFolder:folder];
        [self setReturnCodes];
    }
    return self;
}

// Get the URL from the FinderFolder items
// and call the setUpPath: method.
- (void)setUpPathsForFinderFolder:(FinderFolder *)folder {
    NSURL *url = [NSURL URLWithString:[folder URL]];
    [self setUpPath:url];
}

// Sets up the required paths, the new files name and the command
// that NSTask will run. Runs when instance is initialized.
- (void)setUpPath:(NSURL *)url {
    // Get the name for the new file (foldername)
    // and relevant paths (folderPath + parentFolder).
    self.folderPath = [url path];
    self.folderName = [url lastPathComponent];
    self.fileURL = url;
    self.fileSizeInBytes = 0.0;
    
    // Calculate the size of the folder, by going through all of
    // its contents. Done in another thread, but maybe not really
    // necessary to do so.
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSError *error = nil;
    NSArray *contentsOfDirectory = [fileManager contentsOfDirectoryAtPath:self.folderPath error:&error];
    NSDictionary *fileAttributes;
    for (NSString* item in contentsOfDirectory) {
        NSString *fullItemPath = [NSString stringWithFormat:@"%@/%@", self.folderPath, item];
        fileAttributes = [fileManager attributesOfItemAtPath:fullItemPath error:&error];
        self.fileSizeInBytes = self.fileSizeInBytes + [[fileAttributes valueForKeyPath:NSFileSize] intValue];
    }
    // Check if the foldername has been set, otherwise
    // get it by substringing the full path string.
    if (self.folderName == nil) {
        self.folderName = [url path];
        NSRange lastSlashCharacter = [[self folderPath] rangeOfString:@"/"
                                                              options:NSBackwardsSearch];
        NSRange rangeOfFolderPath = NSMakeRange(0, lastSlashCharacter.location+1);
        self.folderName = [[self folderName] stringByReplacingCharactersInRange:rangeOfFolderPath
                                                                     withString:@""];
    }
    
    // And get the parent folder. This is necessary for
    // the zip tool.
    NSRange range = NSMakeRange([[self folderPath] length] - [[self folderName] length],
                                [[self folderName] length]);
    self.parentFolder = [[self folderPath] stringByReplacingCharactersInRange:range
                                                                   withString:@""];
    // Set the new name for the file to be created
    // Add (#) infront of the issue number in the
    // filename with regex.
    error = nil;
    NSRegularExpression *regularExpression = [NSRegularExpression regularExpressionWithPattern:kCZRegExPattern
                                                                                       options:0
                                                                                         error:&error];
    range = NSMakeRange(0, [[self folderName] length]);
    NSString *newFileName = [regularExpression stringByReplacingMatchesInString:[self folderName]
                                                                        options:0
                                                                          range:range
                                                                   withTemplate:kCZRegExTemplate];
    // Check that the filename is not already taken
    self.archivePath = [NSString stringWithFormat:@"%@%@.cbz", [self parentFolder], newFileName];
    // Make sure the file name is not already taken.
    int i = 1;
    while ([fileManager fileExistsAtPath:[self archivePath]]) {
        self.archivePath = [NSString stringWithFormat:@"%@%@-%d.cbz", [self parentFolder], newFileName, i++];
    }
}

#pragma mark COMPRESSION METHODS

- (void)setUpCommandline {
    // Get the files to ignore
    NSString *excludeString = @"-x";
    NSArray *filesToExclude = [[self filesToIgnore] componentsSeparatedByString:@", "];
    NSMutableString *ignoreParameter = [[NSMutableString alloc] init];
    for (NSString *file in filesToExclude) {
        if ([file length] > 0) {
            if ([ignoreParameter isEqualToString:@""]) {
                [ignoreParameter appendString:excludeString];
            }
            [ignoreParameter appendFormat:@" \\*%@", file];
        }
    }
    self.commandLine = [NSString stringWithFormat:@"zip -jr \"%@\" \"%@\" %@", [self archivePath], [self folderPath], ignoreParameter];
}

// Starts the compression process. Invoked by AppDelegate.
- (void)startCompression {
    // Initialize NSTask, NSPipe and NSFileHandle objects
    self.task = [[NSTask alloc] init];
    NSPipe *outputPipe = [[NSPipe alloc] init];
    NSPipe *errorPipe = [[NSPipe alloc] init];
    NSFileHandle *outputFileHandle = [outputPipe fileHandleForReading];
    NSFileHandle *errorFileHandle = [errorPipe fileHandleForReading];
    
    // Prepare task
    [self setUpCommandline];
    [[self task] setLaunchPath:kCZLaunchPath];
    [[self task] setArguments:@[ @"-c", [self commandLine] ]];
    [[self task] setStandardOutput:outputPipe];
    [[self task] setStandardError:errorPipe];
    // Create an NSNotificationCenter object for
    // monitoring the NSTask process
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self
                           selector:@selector(receivedData:)
                               name:NSFileHandleReadCompletionNotification
                             object:outputFileHandle];
    [notificationCenter addObserver:self
                           selector:@selector(receivedError:)
                               name:NSFileHandleReadCompletionNotification
                             object:errorFileHandle];
    [notificationCenter addObserver:self
                           selector:@selector(taskTerminated:)
                               name:NSTaskDidTerminateNotification
                             object:self.task];
    // Monitor process in the background and
    // posts a notification when called.
    [outputFileHandle readInBackgroundAndNotify];
    [errorFileHandle readInBackgroundAndNotify];

    // Begin the compression
    [[self task] launch];
    [[self task] waitUntilExit];
}

#pragma mark NOTIFICATIONS

- (void)receivedData:(NSNotification *)notification {
    if (![self isRunning] && ![self isArchived]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[self delegate] compressionDidStart:self];
        });
        [self setRunning:YES];
    }
    
    [[notification object] readInBackgroundAndNotify];
}

- (void)receivedError:(NSNotification *)notification {
    NSData *data = [[notification userInfo] objectForKey:NSFileHandleNotificationDataItem];
    if (!data) {
        [[self delegate] compressionCouldNotFinish:self errorMessage:@"stopping compression..."];
    }
    
    [[notification object] readInBackgroundAndNotify];
}

// Should be called after the task is done,
// but check the task status just to be sure.
- (void)taskTerminated:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (![[self task] isRunning]) {
            if ([[self task] terminationStatus] == CZ_ZIP_RETURN_CODE_OK) {
                [[self task] terminate];
                [self setArchived:YES];
                [self setRunning:NO];
                [[self delegate] compressionDidEnd:self];
            } else {
                [[self task] terminate];
                [[self delegate] compressionCouldNotFinish:self errorMessage:[[self returnCodes] objectAtIndex:[[self task] terminationStatus]]];
            }
        }
    });
}

// Sets up the return codes
// from the zip command.
- (void)setReturnCodes {
    _returnCodes = @[ @"normal; No errors or warning detected.", @"-", @"unexpected end of zip file.",
                      @"a generic error in the zipfile format was detected. Processing may have completed successfully anyway; some bro-ken zipfiles created by other archivers have simple work-arounds.",
                      @"zip was unable to allocate memory for one or more buffersduring program initialization.",
                      @"a severe error in the zipfile format was detected.  Pro-cessing probably failed immediately.",
                      @"entry too large to split (with zipsplit), read, or write",
                      @"invalid comment format",
                      @"zip -T failed or out of memory",
                      @"the user aborted zip prematurely with control-C (or similar)",
                      @"zip encountered an error while using a temp file",
                      @"read or seek error",
                      @"zip has nothing to do",
                      @"missing or empty zip file",
                      @"error writing to a file",
                      @"zip was unable to create a file to write to",
                      @"bad command line parameters",
                      @"zip could not open a specified file to read"
                      ];
}

@end