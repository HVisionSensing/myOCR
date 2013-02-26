//
//  TesseractWrapper.h
//  MyOCRFixed
//
//  Created by Ruxandra Nistor on 5/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//


namespace tesseract {
    class TessBaseAPI;
};

typedef enum {
    kEng,
    kRon,
    kEng2
} Language;

@interface TesseractWrapper : NSObject {
	tesseract::TessBaseAPI *tesseract;
	uint32_t *pixels;
}
@property Language language;


- (TesseractWrapper *) initWithLanguage:(Language) lang;
- (NSString *) recognizeImage: (UIImage *) image;
- (void) changeLanguage: (Language) lang;
@end
