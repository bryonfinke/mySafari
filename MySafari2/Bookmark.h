//
//  Bookmark.h
//  
//
//  Created by Bryon Finke on 6/14/15.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Bookmark : NSManagedObject

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * url;

@end
