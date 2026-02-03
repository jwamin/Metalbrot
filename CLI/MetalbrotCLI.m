#import <Foundation/Foundation.h>
#import <Metal/Metal.h>
#import <ImageIO/ImageIO.h>
#import <CoreGraphics/CoreGraphics.h>
#import <UniformTypeIdentifiers/UniformTypeIdentifiers.h>
#import <simd/simd.h>

typedef struct {
    vector_float2 center;
    float scale;
    uint32_t maxIter;
    uint32_t colorScheme;
    uint32_t pad0;
    vector_uint2 viewport;
} MetalbrotCLIParams;

typedef struct {
    float position[2];
    float uv[2];
} MetalbrotVertex;

static void printUsage(void) {
    printf("MetalbrotCLI - Render a Mandelbrot PNG using Metal\n\n");
    printf("Options:\n");
    printf("  --width <px>        Image width (default: 1920)\n");
    printf("  --height <px>       Image height (default: 1080)\n");
    printf("  --center-x <float>  Center real coordinate (default: -0.5)\n");
    printf("  --center-y <float>  Center imaginary coordinate (default: 0.0)\n");
    printf("  --scale <float>     Half-width in complex plane (default: 1.5)\n");
    printf("  --max-iter <int>    Max iterations (default: 500)\n");
    printf("  --scheme <int>      Color scheme 0-9 (default: 0)\n");
    printf("  --output <path>     Output PNG path (default: ./mandelbrot.png)\n");
    printf("  --help              Show this help\n");
}

static NSString *nextArg(NSArray<NSString *> *args, NSInteger *index) {
    if (*index + 1 >= (NSInteger)args.count) {
        return nil;
    }
    *index += 1;
    return args[*index];
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSUInteger width = 1920;
        NSUInteger height = 1080;
        double centerX = -0.5;
        double centerY = 0.0;
        double scale = 1.5;
        uint32_t maxIter = 500;
        uint32_t scheme = 0;
        NSString *outputPath = @"./mandelbrot.png";

        NSArray<NSString *> *args = [[NSProcessInfo processInfo] arguments];
        for (NSInteger i = 1; i < (NSInteger)args.count; i++) {
            NSString *arg = args[i];
            if ([arg isEqualToString:@"--help"]) {
                printUsage();
                return 0;
            } else if ([arg isEqualToString:@"--width"]) {
                NSString *value = nextArg(args, &i);
                if (!value) { printUsage(); return 1; }
                width = (NSUInteger)value.integerValue;
            } else if ([arg isEqualToString:@"--height"]) {
                NSString *value = nextArg(args, &i);
                if (!value) { printUsage(); return 1; }
                height = (NSUInteger)value.integerValue;
            } else if ([arg isEqualToString:@"--center-x"]) {
                NSString *value = nextArg(args, &i);
                if (!value) { printUsage(); return 1; }
                centerX = value.doubleValue;
            } else if ([arg isEqualToString:@"--center-y"]) {
                NSString *value = nextArg(args, &i);
                if (!value) { printUsage(); return 1; }
                centerY = value.doubleValue;
            } else if ([arg isEqualToString:@"--scale"]) {
                NSString *value = nextArg(args, &i);
                if (!value) { printUsage(); return 1; }
                scale = value.doubleValue;
            } else if ([arg isEqualToString:@"--max-iter"]) {
                NSString *value = nextArg(args, &i);
                if (!value) { printUsage(); return 1; }
                maxIter = (uint32_t)value.intValue;
            } else if ([arg isEqualToString:@"--scheme"]) {
                NSString *value = nextArg(args, &i);
                if (!value) { printUsage(); return 1; }
                int parsed = value.intValue;
                scheme = (parsed < 0 || parsed >= 10) ? 0 : (uint32_t)parsed;
            } else if ([arg isEqualToString:@"--output"]) {
                NSString *value = nextArg(args, &i);
                if (!value) { printUsage(); return 1; }
                outputPath = value;
            } else {
                fprintf(stderr, "Unknown argument: %s\n", arg.UTF8String);
                printUsage();
                return 1;
            }
        }

        if (width == 0 || height == 0 || scale <= 0.0) {
            fprintf(stderr, "Invalid dimensions or scale.\n");
            return 1;
        }

        id<MTLDevice> device = MTLCreateSystemDefaultDevice();
        if (!device) {
            fprintf(stderr, "Metal device not available.\n");
            return 1;
        }

        id<MTLCommandQueue> commandQueue = [device newCommandQueue];
        if (!commandQueue) {
            fprintf(stderr, "Failed to create command queue.\n");
            return 1;
        }

        id<MTLLibrary> library = [device newDefaultLibrary];

        id<MTLFunction> vertexFn = [library newFunctionWithName:@"mbrot_vertex_main"];
        id<MTLFunction> iterFn = [library newFunctionWithName:@"mbrot_iter_fragment"];
        id<MTLFunction> colorFn = [library newFunctionWithName:@"mbrot_color_fragment"];
        if (!vertexFn || !iterFn || !colorFn) {
            fprintf(stderr, "Missing Metal shader functions.\n");
            return 1;
        } else {
            fprintf(stderr, "Looks like it worked.\n");
        }

        MTLVertexDescriptor *vertexDesc = [MTLVertexDescriptor vertexDescriptor];
        vertexDesc.attributes[0].format = MTLVertexFormatFloat2;
        vertexDesc.attributes[0].offset = 0;
        vertexDesc.attributes[0].bufferIndex = 0;
        vertexDesc.attributes[1].format = MTLVertexFormatFloat2;
        vertexDesc.attributes[1].offset = sizeof(float) * 2;
        vertexDesc.attributes[1].bufferIndex = 0;
        vertexDesc.layouts[0].stride = sizeof(MetalbrotVertex);

        MTLRenderPipelineDescriptor *iterDesc = [MTLRenderPipelineDescriptor new];
        iterDesc.vertexFunction = vertexFn;
        iterDesc.fragmentFunction = iterFn;
        iterDesc.vertexDescriptor = vertexDesc;
        iterDesc.colorAttachments[0].pixelFormat = MTLPixelFormatR32Float;

        MTLRenderPipelineDescriptor *colorDesc = [MTLRenderPipelineDescriptor new];
        colorDesc.vertexFunction = vertexFn;
        colorDesc.fragmentFunction = colorFn;
        colorDesc.vertexDescriptor = vertexDesc;
        colorDesc.colorAttachments[0].pixelFormat = MTLPixelFormatBGRA8Unorm;

        NSError *pipelineError = nil;
        id<MTLRenderPipelineState> iterPipeline = [device newRenderPipelineStateWithDescriptor:iterDesc error:&pipelineError];
        if (!iterPipeline) {
            fprintf(stderr, "Failed to create iteration pipeline: %s\n", pipelineError.localizedDescription.UTF8String);
            return 1;
        }
        pipelineError = nil;
        id<MTLRenderPipelineState> colorPipeline = [device newRenderPipelineStateWithDescriptor:colorDesc error:&pipelineError];
        if (!colorPipeline) {
            fprintf(stderr, "Failed to create color pipeline: %s\n", pipelineError.localizedDescription.UTF8String);
            return 1;
        }

        MTLTextureDescriptor *iterTexDesc = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:MTLPixelFormatR32Float
                                                                                                width:width
                                                                                               height:height
                                                                                            mipmapped:NO];
        iterTexDesc.usage = MTLTextureUsageRenderTarget | MTLTextureUsageShaderRead;
        iterTexDesc.storageMode = MTLStorageModePrivate;
        id<MTLTexture> iterTexture = [device newTextureWithDescriptor:iterTexDesc];

        MTLTextureDescriptor *colorTexDesc = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:MTLPixelFormatBGRA8Unorm
                                                                                                 width:width
                                                                                                height:height
                                                                                             mipmapped:NO];
        colorTexDesc.usage = MTLTextureUsageRenderTarget | MTLTextureUsageShaderRead;
        colorTexDesc.storageMode = MTLStorageModeShared;
        id<MTLTexture> colorTexture = [device newTextureWithDescriptor:colorTexDesc];

        if (!iterTexture || !colorTexture) {
            fprintf(stderr, "Failed to allocate textures.\n");
            return 1;
        }

        MetalbrotVertex quad[4] = {
            { { -1.0f, -1.0f }, { 0.0f, 1.0f } },
            { { -1.0f,  1.0f }, { 0.0f, 0.0f } },
            { {  1.0f, -1.0f }, { 1.0f, 1.0f } },
            { {  1.0f,  1.0f }, { 1.0f, 0.0f } },
        };

        id<MTLBuffer> vertexBuffer = [device newBufferWithBytes:quad
                                                         length:sizeof(quad)
                                                        options:MTLResourceStorageModeShared];
        if (!vertexBuffer) {
            fprintf(stderr, "Failed to create vertex buffer.\n");
            return 1;
        }

        MetalbrotCLIParams params;
        params.center = (vector_float2){ (float)centerX, (float)centerY };
        params.scale = (float)scale;
        params.maxIter = maxIter;
        params.colorScheme = scheme;
        params.pad0 = 0;
        params.viewport = (vector_uint2){ (uint32_t)width, (uint32_t)height };
        id<MTLBuffer> paramsBuffer = [device newBufferWithBytes:&params
                                                         length:sizeof(params)
                                                        options:MTLResourceStorageModeShared];
        if (!paramsBuffer) {
            fprintf(stderr, "Failed to create params buffer.\n");
            return 1;
        }

        // Command buffer encodes all GPU work for this frame.
        id<MTLCommandBuffer> commandBuffer = [commandQueue commandBuffer];
        commandBuffer.label = @"MetalbrotCLI Render";

        MTLRenderPassDescriptor *iterPass = [MTLRenderPassDescriptor renderPassDescriptor];
        iterPass.colorAttachments[0].texture = iterTexture;
        // Clear the iteration target and store results for the next pass to sample.
        iterPass.colorAttachments[0].loadAction = MTLLoadActionClear;
        iterPass.colorAttachments[0].storeAction = MTLStoreActionStore;
        iterPass.colorAttachments[0].clearColor = MTLClearColorMake(0, 0, 0, 1);

        id<MTLRenderCommandEncoder> iterEncoder = [commandBuffer renderCommandEncoderWithDescriptor:iterPass];
        MTLViewport viewport = {0.0, 0.0, (double)width, (double)height, 0.0, 1.0};
        // Ensure the render area matches the offscreen texture size.
        [iterEncoder setViewport:viewport];
        // Deferred render step 1: encode the iteration pass into an offscreen texture (iterTexture).
        [iterEncoder setRenderPipelineState:iterPipeline];
        [iterEncoder setVertexBuffer:vertexBuffer offset:0 atIndex:0];
        [iterEncoder setFragmentBuffer:paramsBuffer offset:0 atIndex:0];
        [iterEncoder drawPrimitives:MTLPrimitiveTypeTriangleStrip vertexStart:0 vertexCount:4];
        [iterEncoder endEncoding];

        MTLRenderPassDescriptor *colorPass = [MTLRenderPassDescriptor renderPassDescriptor];
        colorPass.colorAttachments[0].texture = colorTexture;
        // Clear the color target and store results for CPU readback.
        colorPass.colorAttachments[0].loadAction = MTLLoadActionClear;
        colorPass.colorAttachments[0].storeAction = MTLStoreActionStore;
        colorPass.colorAttachments[0].clearColor = MTLClearColorMake(0, 0, 0, 1);

        id<MTLRenderCommandEncoder> colorEncoder = [commandBuffer renderCommandEncoderWithDescriptor:colorPass];
        // Deferred render step 2: shade into the color texture by sampling iterTexture.
        [colorEncoder setViewport:viewport];
        [colorEncoder setRenderPipelineState:colorPipeline];
        [colorEncoder setVertexBuffer:vertexBuffer offset:0 atIndex:0];
        [colorEncoder setFragmentBuffer:paramsBuffer offset:0 atIndex:0];
        [colorEncoder setFragmentTexture:iterTexture atIndex:0];
        [colorEncoder drawPrimitives:MTLPrimitiveTypeTriangleStrip vertexStart:0 vertexCount:4];
        [colorEncoder endEncoding];

        NSUInteger bytesPerRow = width * 4;
        NSUInteger bufferLength = bytesPerRow * height;
        id<MTLBuffer> readbackBuffer = [device newBufferWithLength:bufferLength
                                                           options:MTLResourceStorageModeShared];
        if (!readbackBuffer) {
            fprintf(stderr, "Failed to allocate readback buffer.\n");
            return 1;
        }

        // Submit the command buffer to the GPU and block until all work completes.
        [commandBuffer commit];
        [commandBuffer waitUntilCompleted];
        if (commandBuffer.error) {
            fprintf(stderr, "Metal error: %s\n", commandBuffer.error.localizedDescription.UTF8String);
            return 1;
        }

        void *bytes = [readbackBuffer contents];
        [colorTexture getBytes:bytes
                   bytesPerRow:bytesPerRow
                    fromRegion:MTLRegionMake2D(0, 0, width, height)
                   mipmapLevel:0];
        CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, bytes, bufferLength, NULL);
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGBitmapInfo bitmapInfo = kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst;
        CGImageRef image = CGImageCreate(width,
                                         height,
                                         8,
                                         32,
                                         bytesPerRow,
                                         colorSpace,
                                         bitmapInfo,
                                         provider,
                                         NULL,
                                         false,
                                         kCGRenderingIntentDefault);

        if (!image) {
            fprintf(stderr, "Failed to create CGImage.\n");
            CGColorSpaceRelease(colorSpace);
            CGDataProviderRelease(provider);
            return 1;
        }

        NSURL *outputURL = [NSURL fileURLWithPath:outputPath];
        CGImageDestinationRef destination = CGImageDestinationCreateWithURL((__bridge CFURLRef)outputURL,
                                                                           (__bridge CFStringRef)UTTypePNG.identifier,
                                                                           1,
                                                                           NULL);
        if (!destination) {
            fprintf(stderr, "Failed to create image destination.\n");
            CGImageRelease(image);
            CGColorSpaceRelease(colorSpace);
            CGDataProviderRelease(provider);
            return 1;
        }

        CGImageDestinationAddImage(destination, image, NULL);
        if (!CGImageDestinationFinalize(destination)) {
            fprintf(stderr, "Failed to write PNG.\n");
            CFRelease(destination);
            CGImageRelease(image);
            CGColorSpaceRelease(colorSpace);
            CGDataProviderRelease(provider);
            return 1;
        }

        CFRelease(destination);
        CGImageRelease(image);
        CGColorSpaceRelease(colorSpace);
        CGDataProviderRelease(provider);

        printf("Wrote %s (%lux%lu)\n", outputPath.UTF8String, (unsigned long)width, (unsigned long)height);
    }
    return 0;
}
