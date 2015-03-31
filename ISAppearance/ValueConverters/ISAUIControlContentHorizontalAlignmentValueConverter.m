//
//

#import "ISAUIControlContentHorizontalAlignmentValueConverter.h"


@implementation ISAUIControlContentHorizontalAlignmentValueConverter {

}

- (id)init {
    self = [super init];
    if (self) {
        self.mapping = @{
                @"UIControlContentHorizontalAlignmentCenter" : @(UIControlContentHorizontalAlignmentCenter),
                @"UIControlContentHorizontalAlignmentLeft" : @(UIControlContentHorizontalAlignmentLeft),
                @"UIControlContentHorizontalAlignmentRight" : @(UIControlContentHorizontalAlignmentRight),
                @"UIControlContentHorizontalAlignmentFill" : @(UIControlContentHorizontalAlignmentFill),

                @"center" : @(UIControlContentHorizontalAlignmentCenter),
                @"left" : @(UIControlContentHorizontalAlignmentLeft),
                @"right" : @(UIControlContentHorizontalAlignmentRight),
                @"fill" : @(UIControlContentHorizontalAlignmentFill),
        };
    }
    return self;
}

@end