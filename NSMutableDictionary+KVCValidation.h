//
//  NSMutableDictionary+KVCValidation.h
//
//  Created by Mugginsoft on 13/12/2012.
//
//

#import <Cocoa/Cocoa.h>

@protocol NSMutableDictionary_KVCValidationDelegate <NSObject>
@required
- (BOOL)validateValue:(id *)ioValue forKey:(NSString *)key error:(NSError **)outError sender:(NSMutableDictionary *)sender;
@end

@interface NSMutableDictionary (KVCValidation)
- (void)setValidationDelegate:(id <NSMutableDictionary_KVCValidationDelegate>)validationDelegate;
- (id)validationDelegate;
@end
