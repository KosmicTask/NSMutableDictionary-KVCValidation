//
//  NSMutableDictionary+KVCValidation.m
//
//  Created by Mugginsoft on 13/12/2012.
//
//

#import "NSMutableDictionary+KVCValidation.h"
#import <objc/runtime.h>

const char validationDelegateKey;

/*
 
 MethodSwizzle()
 
 ref: http://www.mikeash.com/pyblog/friday-qa-2010-01-29-method-replacement-for-fun-and-profit.html

 */
void MethodSwizzle(Class klass, SEL origSEL, SEL overrideSEL)
{
    Method origMethod = class_getInstanceMethod(klass, origSEL);
    Method overrideMethod = class_getInstanceMethod(klass, overrideSEL);
    
    // try and add instance method with original selector that points to new implementation
    if (class_addMethod(klass, origSEL, method_getImplementation(overrideMethod), method_getTypeEncoding(overrideMethod))) {
        
        // add or replace method so that new selector points to original method 
        class_replaceMethod(klass, overrideSEL, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
    } else {
        
        // class already has an override method so just swap the implementations.
        method_exchangeImplementations(origMethod, overrideMethod);
    }
}

@implementation NSMutableDictionary (KVCValidation)

/*
 
 + load
 
 */
+ (void)load
{
    MethodSwizzle(self, @selector(validateValue:forKey:error:), @selector(swizzle_validateValue:forKey:error:));
}
    
/*
 
 - setValidationDelegate:
 
 */
- (void)setValidationDelegate:(id)validationDelegate
{
    objc_setAssociatedObject(self, &validationDelegateKey, validationDelegate, OBJC_ASSOCIATION_RETAIN);
}

/*
 
 - validationDelegate
 
 */
- (id)validationDelegate
{
    return objc_getAssociatedObject(self, &validationDelegateKey);
}

/*
 
 - swizzle_validateValue:forKey:error:
 
 */
- (BOOL)swizzle_validateValue:(id *)ioValue forKey:(NSString *)key error:(NSError **)outError
{
    id validationDelegate = self.validationDelegate;
    SEL validationSelector = @selector(validateValue:forKey:error:sender:);
    BOOL isValid = NO;
    
    if ([validationDelegate respondsToSelector:validationSelector]) {
        isValid = [validationDelegate validateValue:ioValue forKey:key error:outError sender:self];
    } else {
        // remember, we swap IMPS at run time
        isValid = [self swizzle_validateValue:ioValue forKey:key error:outError];
    }
    
    return isValid;
}
@end
