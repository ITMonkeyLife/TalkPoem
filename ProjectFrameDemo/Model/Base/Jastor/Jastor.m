#import "Jastor.h"
#import "JastorRuntimeHelper.h"

@implementation Jastor

@synthesize objectId;
static NSString *idPropertyName = @"id";
static NSString *idPropertyNameOnObject = @"objectId";

Class nsDictionaryClass;
Class nsArrayClass;
Class nsMutableArrayClass;

+ (id)objectFromDictionary:(NSDictionary*)dictionary {
    if (![dictionary isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    id item = [[[self alloc] initWithDictionary:dictionary] autorelease];
    return item;
}

- (id)initWithDictionary:(NSDictionary *)dictionary {
	if (!nsDictionaryClass) nsDictionaryClass = [NSDictionary class];
	if (!nsArrayClass) nsArrayClass = [NSArray class];
    if (!nsMutableArrayClass) nsMutableArrayClass = [NSMutableArray class];
    
	if ((self = [super init])) {
        for(NSString *classAttrName in [JastorRuntimeHelper propertyNames:[self class]])
        {
            id value = nil;
            NSString *jsonKey = classAttrName;

            if ([self respondsToSelector:@selector(attrMapDict)]) {
                jsonKey = [self attrMapDict][classAttrName];
                jsonKey = (jsonKey) ? (jsonKey):(classAttrName);
            }

            if ([dictionary isKindOfClass:[NSDictionary class]]) {
                value = [dictionary valueForKey:jsonKey];
                
                if (value == [NSNull null] || value == nil) {
                    continue;
                }
                
                if ([JastorRuntimeHelper isPropertyReadOnly:[self class] propertyName:classAttrName]) {
                    continue;
                }
                
                // handle dictionary
                if ([value isKindOfClass:nsDictionaryClass]) {
                    Class klass = [JastorRuntimeHelper propertyClassForPropertyName:classAttrName ofClass:[self class]];
                    if (![klass isSubclassOfClass:[Jastor class]]) {
//                        NSLog(@"服务器返回的数据类型和客户端不一致");
                    }else{
                        value = [[[klass alloc] initWithDictionary:value] autorelease];
                    }
                }
                // handle array
                else if ([value isKindOfClass:nsArrayClass] || [value isKindOfClass:nsMutableArrayClass]) {
                    Class klass = [JastorRuntimeHelper propertyClassForPropertyName:classAttrName ofClass:[self class]];
                    if (![NSStringFromClass(klass) isEqualToString:NSStringFromClass(nsArrayClass)] && ![NSStringFromClass(klass) isEqualToString:NSStringFromClass(nsMutableArrayClass)]) {
//                        NSLog(@"服务器返回的数据类型和客户端不一致");
//                        continue;
                    }else{
                        Class arrayItemType = [[self class] performSelector:NSSelectorFromString([NSString stringWithFormat:@"%@_class", jsonKey])];
                        
                        NSMutableArray *childObjects = [NSMutableArray arrayWithCapacity:[(NSArray*)value count]];
                        
                        for (id child in value) {
                            if ([[child class] isSubclassOfClass:nsDictionaryClass]) {
                                Jastor *childDTO = [[[arrayItemType alloc] initWithDictionary:child] autorelease];
                                [childObjects addObject:childDTO];
                            } else {
                                [childObjects addObject:child];
                            }
                        }
                        
                        value = childObjects;
                    }
                }
                // handle nsnumber
                else if([value isKindOfClass:[NSNumber class]]){
                    value = [(NSNumber *)value stringValue];
                }

            }
            
			// handle all others
            if (value) {
                [self setValue:value forKey:classAttrName];
            }
		}
		
	}
	return self;	
}

+ (id)objectFromArray:(NSArray*)array
{
    id item = [[[self alloc] initWithArray:array] autorelease];
    return item;
}

- (id)initWithArray:(NSArray *)array
{
    if (!nsDictionaryClass) nsDictionaryClass = [NSDictionary class];
    if (!nsArrayClass) nsArrayClass = [NSArray class];
    if (!nsMutableArrayClass) nsMutableArrayClass = [NSMutableArray class];
    
	if ((self = [super init])) {
        NSLog(@"%@",[JastorRuntimeHelper propertyNames:[self class]]);
		for (NSString *key in [JastorRuntimeHelper propertyNames:[self class]]) {
            id value = nil;
            if([array isKindOfClass:[NSArray class]] || [array isKindOfClass:[NSMutableArray class]]){
                Class klass = [JastorRuntimeHelper propertyClassForPropertyName:key ofClass:[self class]];
                if (![NSStringFromClass(klass) isEqualToString:NSStringFromClass(nsArrayClass)]&& ![NSStringFromClass(klass) isEqualToString:NSStringFromClass(nsMutableArrayClass)]) {
                    NSLog(@"服务器返回的数据类型和客户端不一致");
                    continue;
                }
                Class arrayItemType = [[self class] performSelector:NSSelectorFromString([NSString stringWithFormat:@"%@_class", key])];
                
                NSMutableArray *childObjects = [NSMutableArray arrayWithCapacity:[(NSArray*)array count]];
                
                for (id child in array) {
                    if ([[child class] isSubclassOfClass:nsDictionaryClass]) {
                        Jastor *childDTO = [[[arrayItemType alloc] initWithDictionary:child] autorelease];
                        [childObjects addObject:childDTO];
                    } else {
                        [childObjects addObject:child];
                    }
                }
                
                value = childObjects;
            }
            // handle all others
            if (value) {
                [self setValue:value forKey:key];
            }
		}
	}
	return self;
    
}
- (void)dealloc {
	self.objectId = nil;
	
//	for (NSString *key in [JastorRuntimeHelper propertyNames:[self class]]) {
//		//[self setValue:nil forKey:key];
//	}
	
	[super dealloc];
}

- (void)encodeWithCoder:(NSCoder*)encoder {
	[encoder encodeObject:self.objectId forKey:idPropertyNameOnObject];
	for (NSString *key in [JastorRuntimeHelper propertyNames:[self class]]) {
		[encoder encodeObject:[self valueForKey:key] forKey:key];
	}
}

- (id)initWithCoder:(NSCoder *)decoder {
	if ((self = [super init])) {
		[self setValue:[decoder decodeObjectForKey:idPropertyNameOnObject] forKey:idPropertyNameOnObject];
		
		for (NSString *key in [JastorRuntimeHelper propertyNames:[self class]]) {
            if ([JastorRuntimeHelper isPropertyReadOnly:[self class] propertyName:key]) {
                continue;
            }
			id value = [decoder decodeObjectForKey:key];
			if (value != [NSNull null] && value != nil) {
				[self setValue:value forKey:key];
			}
		}
	}
	return self;
}

- (NSMutableDictionary *)toDictionary {
	NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    if (self.objectId) {
        [dic setObject:self.objectId forKey:idPropertyName];
    }
	
	for (NSString *key in [JastorRuntimeHelper propertyNames:[self class]]) {
		id value = [self valueForKey:key];
        if (value && [value isKindOfClass:[Jastor class]]) {            
            [dic setObject:[value toDictionary] forKey:key];
        } else if (value && [value isKindOfClass:[NSArray class]] && ((NSArray*)value).count > 0) {
            id internalValue = [value objectAtIndex:0];
            if (internalValue && [internalValue isKindOfClass:[Jastor class]]) {
                NSMutableArray *internalItems = [NSMutableArray array];
                for (id item in value) {
                    [internalItems addObject:[item toDictionary]];
                }
                [dic setObject:internalItems forKey:key];
            } else {
                [dic setObject:value forKey:key];
            }
        } else if (value != nil) {
            [dic setObject:value forKey:key];
        }else{
            [dic setObject:[NSNull null] forKey:key];
        }
	}
    return dic;
}

- (NSString *)description {
    NSMutableDictionary *dic = [self toDictionary];
	
	return [NSString stringWithFormat:@"#<%@: id = %@ %@>", [self class], self.objectId, [dic description]];
}

- (BOOL)isEqual:(id)object {
	if (object == nil || ![object isKindOfClass:[Jastor class]]) return NO;
	
	Jastor *model = (Jastor *)object;
	
	return [self.objectId isEqualToString:model.objectId];
}

@end
