//
//  CZCompress.h
//  ComicZipper
//
//  Created by Ardalan Samimi on 07/10/15.
//  Copyright © 2015 Ardalan Samimi. All rights reserved.
//

#import <ZipUtilities/ZipUtilities.h>

@interface CZCompressRequest : NOZCompressRequest

@property (nonatomic) NSArray *ignoreFiles;
@property (nonatomic) BOOL ignoreEmptyData;

@end
