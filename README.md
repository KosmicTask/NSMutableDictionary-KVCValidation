NSMutableDictionary-KVCValidation
=================================

A Cocoa NSMutableDictionary category that enables routing of KVC validation methods to a delegate.

An NSMutableArray of NSMutableDictionary instances can be bound, via an NSArrayController, to a table view, however validating the view's changes to the NSMutableDictionary model is hard. This category swizzles the NSMutableDictionary `validateValue:forKey:error:` method to call out to delegate for easy validation.


#Usage

Assign the delegate:

	NSMutableDictionary *connection = [self selectedConnection];
    connection.validationDelegate = self;

Implement the `NSMutableDictionary_KVCValidationDelegate` protocol in the delegate:

	#pragma mark -
    #pragma mark NSMutableDictionary+KVCValidation protocol

    /*
     
     - validateValue:forKey:error:sender:
     
     */
    - (BOOL)validateValue:(id *)ioValue forKey:(NSString *)key error:(NSError **)outError sender:(NSMutableDictionary *)sender
    {
    #pragma unused(sender)
        
        BOOL isValid = YES;
        
        if ([key isEqualToString:MGSNetClientKeyPortNumber]) {
            
            if (![*ioValue isKindOfClass:[NSNumber class]] || [*ioValue integerValue] < 1025 || [*ioValue integerValue] > 65535) {
                *outError = [NSError errorWithDomain:@"Application"
                                                code:0
                                            userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"The entered port number is invalid.", @"comment"),
                                        NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Enter a number between 1025 and 65535.", @"comment")
                             }];
                isValid = NO;
            }
        } else if ([key isEqualToString:MGSNetClientKeyAddress]) {
            
            if (![*ioValue isKindOfClass:[NSString class]] || ![(NSString *)*ioValue mgs_isURLorIPAddress]) {
                
                isValid = NO;
                *outError = [NSError errorWithDomain:@"Application"
                                                code:0
                                            userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"The entered address is invalid.", @"comment"),
                                                        NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Enter a valid URL or IP address.", @"comment")
                                                    }];
            }
        }
        
        return isValid;
    }

