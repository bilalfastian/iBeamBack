//
//  AccountsRemoteCaller.h
//  iBeamBack
//
//  Created by Bilal Nazir on 4/13/11.
//  Copyright 2011 iBeamBack. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RemoteCaller.h"

@interface AccountsRemoteCaller : RemoteCaller {
    
}

- (void) getKey;
- (void) signInWithArguments:(NSArray *)args;

@end
