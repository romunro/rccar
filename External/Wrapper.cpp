//
//  Bridge.c
//  RCCar
//
//  Created by Ronan Munro on 29/12/2021.
//

#include "Wrapper.hpp"
#include "NFDriver/NFDriver.h"

using namespace nativeformat::driver;

extern "C" int getIntFromCPP()
{
    
    NF_STUTTER_CALLBACK stutter_callback = [](void *clientdata) {
      printf("Driver Stuttered...\n");
    };

    NF_RENDER_CALLBACK render_callback = [](void *clientdata, float *frames, int numberOfFrames) {
        printf("a");
//      const float samplerate = 2000.0f;
//      const float multiplier = (2.0f * float(M_PI) * samplerate) / float(NF_DRIVER_SAMPLERATE);
//      static unsigned int sinewave = 0;
//      for (int n = 0; n < numberOfFrames; n++) {
//        float audio = sinf(multiplier * sinewave++);
//        for (int i = 0; i < NF_DRIVER_CHANNELS; ++i) {
//          *frames++ = audio;
//        }
//      }
//      return numberOfFrames;
        return 0;

    };
    NF_ERROR_CALLBACK error_callback = [](void *clientdata, const char *errorMessage, int errorCode) {
      printf("Driver Error (%d): %s\n", errorCode, errorMessage);
    };

    NF_WILL_RENDER_CALLBACK will_render_callback = [](void *clientdata) {};

    NF_DID_RENDER_CALLBACK did_render_callback = [](void *clientdata) {};

    NFDriver *driver = nativeformat::driver::NFDriver::createNFDriver(nullptr /* Anything client specific to use in the callbacks */,
                                                          stutter_callback /* called on stutter */,
                                                          render_callback /* called when we have samples to output */,
                                                          error_callback /* called upon driver error */,
                                                          will_render_callback /* Called before render_callback */,
                                                          did_render_callback /* Called after render callback */,
                                                          nativeformat::driver::OutputTypeSoundCard);
    driver->setPlaying(true);
    
    // Create an instance of A, defined in
    // the library, and call getInt() on it:
    return 123;
}
