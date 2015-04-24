//
//  MCTObjectStoreHelpers.h
//  MCTObjectStore
//
//  Created by Skylar Schipper on 4/24/15.
//  Copyright (c) 2015 Ministry Centered Technology. All rights reserved.
//

#ifndef MCTObjectStore_MCTObjectStoreHelpers_h
#define MCTObjectStore_MCTObjectStoreHelpers_h


#if defined(DEBUG) && DEBUG
    #define MCTOSParamAssert(condition) NSAssert((condition), @"Invalid parameter not satisfying: %s", #condition)
#else
    #define MCTOSParamAssert(condition)
#endif

#define MCTOS_EXEC_BLOCK(block, ...) do { if (block) { block(__VA_ARGS__); } } while(0);


#endif
