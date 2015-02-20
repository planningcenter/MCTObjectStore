/*!
 * MCTObjectStack.h
 * MCTObjectStore
 *
 * The MIT License (MIT)
 * Copyright (c) 2015 Ministry Centered Technology
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 *
 * @author Skylar Schipper
 *   @email skylar@pco.bz
 *
 */

#ifndef MCTObjectStore_MCTObjectStack_h
#define MCTObjectStore_MCTObjectStack_h

@import Foundation;
@import CoreData;

@class MCTObjectContext;
@class MCTManagedObject;

@interface MCTObjectStack : NSObject

@property (atomic, strong, readonly) MCTObjectContext *mainContext;
@property (atomic, strong, readonly) MCTObjectContext *privateContext;

- (BOOL)isReady;

+ (instancetype)sharedStack;

- (BOOL)prepareModelWithName:(NSString *)name bundle:(NSBundle *)bundle location:(NSURL *)location error:(NSError **)error;

@end

#endif