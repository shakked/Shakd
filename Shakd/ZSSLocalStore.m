//
//  ZSSLocalStore.m
//  Shakd
//
//  Created by Zachary Shakked on 12/28/14.
//  Copyright (c) 2014 Shakked Inc. All rights reserved.
//

#import "ZSSLocalStore.h"
#import "ZSSUser.h"
#import "ZSSMessage.h"
#import "ZSSFriendRequest.h"

@import CoreData;

@interface ZSSLocalStore()

@property (nonatomic, strong) NSManagedObjectContext *context;
@property (nonatomic, strong) NSManagedObjectModel *model;

@property (nonatomic, strong) NSMutableArray *privateUsers;
@property (nonatomic, strong) NSMutableArray *privateMessages;
@property (nonatomic, strong) NSMutableArray *privateFriendRequests;

@end

@implementation ZSSLocalStore


+ (instancetype)sharedStore {

    static ZSSLocalStore *sharedStore = nil;
    static dispatch_once_t onceToken; // onceToken = 0
    dispatch_once(&onceToken, ^{
        sharedStore = [[self alloc] initPrivate];
    });
    return sharedStore;
}

- (BOOL)saveCoreDataChanges {
    
    NSError *error;
    BOOL successful = [self.context save:&error];
    if (!successful) {
        NSLog(@"Error saving: %@", [error localizedDescription]);
    }
    return successful;
}

- (void)logCoreDataStatus {
    NSLog(@"privateUsers: %@", self.privateUsers);
    NSLog(@"priveteUser count: %lu", [self.privateUsers count]);
    for (ZSSUser *user in self.privateUsers) {
        NSLog(@"username: %@", user.username);
    }
    NSLog(@"priveateMessages: %@", self.privateMessages);
    NSLog(@"privateMessages count: %lu", [self.privateMessages count]);
    NSLog(@"privateFriendRequests: %@", self.privateFriendRequests);
    NSLog(@"privateFriendRequests count: %lu", [self.privateFriendRequests count]);
}

- (NSArray *)users {
    
    if (self.privateUsers) {
        return [self.privateUsers copy];
    } else {
        return @[];
    }
}

- (NSArray *)messages {
    
    if (self.privateMessages) {
        return [self.privateMessages copy];
    } else {
        return @[];
    }
}


- (NSArray *)friendRequests {
    
    if (self.privateFriendRequests) {
        return [self.privateFriendRequests copy];
    } else {
        return @[];
    }
}

- (id)createNewObjectForEntity:(NSString *)entityName
{
    
    if ([entityName isEqual:@"ZSSUser"]) {
        
        ZSSUser *user = [NSEntityDescription insertNewObjectForEntityForName:@"ZSSUser"
                                             inManagedObjectContext:self.context];
        [self.privateUsers addObject:user];
        return user;
        
    } else if ([entityName isEqual:@"ZSSMessage"]) {
        
        ZSSMessage *message = [NSEntityDescription insertNewObjectForEntityForName:@"ZSSMessage"
                                                            inManagedObjectContext:self.context];
        [self.privateMessages addObject:message];
        return message;
        
    } else if ([entityName isEqual:@"ZSSFriendRequest"]) {
        
        ZSSFriendRequest *friendRequest = [NSEntityDescription insertNewObjectForEntityForName:@"ZSSFriendRequest"
                                                                        inManagedObjectContext:self.context];
        [self.privateFriendRequests addObject:friendRequest];
        return friendRequest;
        
    } else {
        @throw [NSException exceptionWithName:@"Invalid Entity"
                                       reason:@"Tried to create an entity with an invalid entity name"
                                     userInfo:nil];
    }
}


- (void)deleteUser:(ZSSUser *)user {
    [self.context deleteObject:user];
    [self.privateUsers removeObject:user];
}

- (void)deleteMessage:(ZSSMessage *)message {
    [self.context deleteObject:message];
    [self.privateMessages removeObject:message];
}

- (void)deleteFriendRequest:(ZSSFriendRequest *)friendRequest {
    [self.context deleteObject:friendRequest];
    [self.privateFriendRequests removeObject:friendRequest];
}

- (ZSSUser *)fetchUserWithObjectId:(NSString *)identifier{
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(objectId == %@)",identifier];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setPredicate:predicate];
    NSEntityDescription *e = [NSEntityDescription entityForName:@"ZSSUser" inManagedObjectContext:self.context];
    request.entity = e;
    
    NSError *error;
    ZSSUser *user = [[self.context executeFetchRequest:request error:&error] firstObject];
    if (!user) {
        NSLog(@"ZSSUser not found for identifier: %@", identifier);
        return nil;
    }
    return user;
}

- (ZSSMessage *)fetchMessageWithObjectId:(NSString *)identifier{
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(objectId == %@)",identifier];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setPredicate:predicate];
    NSEntityDescription *e = [NSEntityDescription entityForName:@"ZSSMessage" inManagedObjectContext:self.context];
    request.entity = e;
    
    NSError *error;
    ZSSMessage *message = [[self.context executeFetchRequest:request error:&error] firstObject];
    if (!message) {
        return nil;
    }
    return message;
}


- (ZSSFriendRequest *)fetchFriendRequestWithObjectId:(NSString *)identifier{
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(objectId == %@)",identifier];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setPredicate:predicate];
    NSEntityDescription *e = [NSEntityDescription entityForName:@"ZSSFriendRequest" inManagedObjectContext:self.context];
    request.entity = e;
    
    NSError *error;
    ZSSFriendRequest *friendRequest = [[self.context executeFetchRequest:request error:&error] firstObject];
    if (!friendRequest) {
        NSLog(@"ZSSFriendRequest not found for identifier: %@", identifier);
        return nil;
    }
    return friendRequest;
}

- (void)deleteAllObjects {
    for (ZSSUser *user in self.users) {
        [self deleteUser:user];
    }
    for (ZSSMessage *message in self.messages) {
        [self deleteMessage:message];
    }
    for (ZSSFriendRequest *friendRequest in self.friendRequests) {
        [self deleteFriendRequest:friendRequest];
    }
    [self saveCoreDataChanges];
}

- (void)throwUserDoesNotExistException:(NSString *)objectId {
    @throw [NSException exceptionWithName:@"UserDoesNotExist"
                                   reason:[NSString stringWithFormat:@"User with objectId: %@ does not exist", objectId]
                                 userInfo:nil];
}

- (void)throwMessageDoesNotExistException:(NSString *)objectId {
    @throw [NSException exceptionWithName:@"MessageDoesNotExist"
                                   reason:[NSString stringWithFormat:@"Message with objectId: %@ does not exist", objectId]
                                 userInfo:nil];
}

- (void)throwFriendRequestDoesNotExistException:(NSString *)objectId {
    @throw [NSException exceptionWithName:@"FriendRequestDoesNotExist"
                                   reason:[NSString stringWithFormat:@"FriendRequest with objectId: %@ does not exist", objectId]
                                 userInfo:nil];
}

- (instancetype)initPrivate {
    
    self = [super init];
    
    if (self) {
        _model = [NSManagedObjectModel mergedModelFromBundles:nil];
        NSPersistentStoreCoordinator *psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:_model];
        NSString *path = [self itemArchivePath];
        NSURL *storeURL = [NSURL fileURLWithPath:path];
        NSError *error = nil;
        
        _context = [[NSManagedObjectContext alloc] init];
        _context.persistentStoreCoordinator = psc;
        
        NSDictionary *options = @{NSMigratePersistentStoresAutomaticallyOption: @YES,
                                  NSInferMappingModelAutomaticallyOption: @YES
                                  };
        BOOL successOfAdding = [psc addPersistentStoreWithType:NSSQLiteStoreType
                                                 configuration:nil
                                                           URL:storeURL
                                                       options:options
                                                         error:&error] != nil;
        if (successOfAdding == NO)
        {
            // Check if the database is there.
            // If it is there, it most likely means that model has changed significantly.
            if ([[NSFileManager defaultManager] fileExistsAtPath:storeURL.path])
            {
                // Delete the database
                [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil];
                // Trying to add a database to the coordinator again
                successOfAdding = [psc addPersistentStoreWithType: NSSQLiteStoreType
                                                    configuration:nil
                                                              URL:storeURL
                                                          options:nil
                                                            error:&error] != nil;
                if (successOfAdding == NO)
                {
                    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                    abort();
                }
            }
        }
        
        [self loadAllItems];
    }
    return self;
}


- (NSString *)itemArchivePath {
    
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                                       NSUserDomainMask,
                                                                       YES);
    NSString *documentDirectory = [documentDirectories firstObject];
    return [documentDirectory stringByAppendingPathComponent:@"store.data"];
}

- (void)loadAllItems {
    
    if (!self.privateUsers) {
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        NSEntityDescription *e = [NSEntityDescription entityForName:@"ZSSUser"
                                             inManagedObjectContext:self.context];
        
        request.entity = e;
        
        
        NSError *error;
        NSArray *result = [self.context executeFetchRequest:request error:&error];
        if (!result) {
            [NSException raise:@"Fetch failed"
                        format:@"Reason: %@", [error localizedDescription]];
        }
        
        self.privateUsers = [[NSMutableArray alloc] initWithArray:result];
    }
    
    if (!self.privateMessages) {
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        NSEntityDescription *e = [NSEntityDescription entityForName:@"ZSSMessage"
                                             inManagedObjectContext:self.context];
        
        request.entity = e;
        
        
        NSError *error;
        NSArray *result = [self.context executeFetchRequest:request error:&error];
        if (!result) {
            [NSException raise:@"Fetch failed"
                        format:@"Reason: %@", [error localizedDescription]];
        }
        
        self.privateMessages = [[NSMutableArray alloc] initWithArray:result];
    }
    
    if (!self.privateFriendRequests) {
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        NSEntityDescription *e = [NSEntityDescription entityForName:@"ZSSFriendRequest"
                                             inManagedObjectContext:self.context];
        
        request.entity = e;
        
        
        NSError *error;
        NSArray *result = [self.context executeFetchRequest:request error:&error];
        if (!result) {
            [NSException raise:@"Fetch failed"
                        format:@"Reason: %@", [error localizedDescription]];
        }
        
        self.privateFriendRequests = [[NSMutableArray alloc] initWithArray:result];
    }
    
    
}

- (instancetype)init
{
    @throw [NSException exceptionWithName:@"Singleton"
                                   reason:@"Use + [ZSSLocalStore sharedStore]"
                                 userInfo:nil];
    return nil;
}



@end