
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include <SDL/SDL.h>
#include <SDL/SDL_image.h>


void BufRev(unsigned char *p) {
  unsigned char *q = p;
  while(q && *q) ++q;
  for(--q; p < q; ++p, --q)
    *p = *p ^ *q,
    *q = *p ^ *q,
    *p = *p ^ *q;
}


void Filter(unsigned char * pixels, int width, int height, int size, char bpp) {
	BufRev(pixels);
}


void HorizontalCopy(unsigned char * pixels, int width, int height, int size, char bpp) {
	
	for(int i = 0; i < height; i++) {
		int line_size =  width * 4;
		
		unsigned char * first_line = malloc(width * 4);
		unsigned char * second_line = malloc(width * 4);
		
		int first_line_offset = (line_size + i) * 4;
		int second_line_offset = (line_size + (height - i)) * 4;
		
		memcpy(first_line, pixels[first_line_offset], line_size);

		memcpy(second_line, pixels[second_line_offset], line_size);

		memcpy(pixels[first_line_offset], second_line, line_size);
		memcpy(pixels[second_line_offset], first_line, line_size);
	}
}

void HorizontalCopy2(unsigned char * pixels, int width, int height, int size, char bpp) {
	for(int x = 0; x < width - 1; x++) {
		for(int y = 0 ; y < height - 1; y++) {
			// const unsigned int offset = ( width * 4 * y ) + x * 4;
			const unsigned int first  = (width * 4 * y ) + x * 4;
			const unsigned int second = (width * 4 * (width - x) ) + (height-y) * 4;
			unsigned char pixel[4];

			pixel[0] = pixels[ first + 0 ];
			pixel[1] = pixels[ first + 1 ];
			pixel[2] = pixels[ first + 2 ];
			pixel[3] = pixels[ first + 3 ];

	
			pixels[ first + 0 ] = pixels[ second + 0 ];
            pixels[ first + 1 ] = pixels[ second + 1 ];
            pixels[ first + 2 ] = pixels[ second + 2 ];
			pixels[ first + 3 ] = pixels[ second + 3 ];


			// pixels[ second + 0 ] = pixel[0];
            // pixels[ second + 1 ] = pixel[1];
            // pixels[ second + 2 ] = pixel[2];
			// pixels[ second + 3 ] = pixel[3];        
		}
	}
	
}

void HorizMiror (unsigned char *buf, int width, int height, int size, char bpp){
	char temp = 0 ;
	for (int w = 0; w < height/2; w++) { // row
		for (int k = 0; k < width; k++) { // colum
			temp = buf [w*width + k]; // zamiana pikseli w kolumnie
			buf [w* width + k] = buf [(height - w - 1)*width + k] ;
			buf [(height - w - 1) + k] = temp ;
		}
	}
}

Uint32 getpixel(SDL_Surface *surface, int x, int y) {
    int bpp = surface->format->BytesPerPixel;
    /* Here p is the address to the pixel we want to retrieve */
    Uint8 *p = (Uint8 *)surface->pixels + y * surface->pitch + x * bpp;

switch (bpp)
{
    case 1:
        return *p;
        break;

    case 2:
        return *(Uint16 *)p;
        break;

    case 3:
        if (SDL_BYTEORDER == SDL_BIG_ENDIAN)
            return p[0] << 16 | p[1] << 8 | p[2];
        else
            return p[0] | p[1] << 8 | p[2] << 16;
            break;

        case 4:
            return *(Uint32 *)p;
            break;

        default:
            return 0;       /* shouldn't happen, but avoids warnings */
      }
}


void set_pixel(SDL_Surface *surface, int x, int y, Uint32 pixel)
{
  Uint32 *target_pixel = (Uint8 *) surface->pixels + y * surface->pitch +
                                                     x * sizeof *target_pixel;
  *target_pixel = pixel;
}

void Negative(SDL_Surface *filtered, SDL_Surface *image) {
	for(int y=0; y<image->h; y++){
		for(int x=0; x<image->w; x++){
			unsigned char pixel[3];
			
		}
	}
}


void blur(unsigned char *buf, int width, int height, char bpp){
	int rowsize=(bpp * 8 * width + 31)/32; //poprawka na długość kolumny
	rowsize *= 4; // kolejne wiersze pikseli są upakowane tak,
	int i=0, j=0, k=0; // aby ich szerokość była wielokrotnością 4 bajtów
	int col=0;
	int * sr= malloc(3*sizeof(int)); //średnie trzech kolorow
	const int blur_size = 3;
	for (i=0;i<height;i+=blur_size){ //kolejne 4 wiersze
		for(j=0;j<rowsize;j+=blur_size * 3){ //kolejne 4 piksele (12B)
			for (col=0; col<3;col++){ //kolejne kolory
				sr[col]=0;
				for(k=0;k<blur_size;k++){ //kolejne 4 kolumny (po 3B)
					sr[col]+=(buf[rowsize*i+j+k*3+col]/=16); // srednia: kazda wartosc /16
					sr[col]+=(buf[rowsize*i+j+rowsize+k*3+col]/=16);
					sr[col]+=(buf[rowsize*i+j+2*rowsize+k*3+col]/=16);
					sr[col]+=(buf[rowsize*i+j+3*rowsize+k*3+col]/=16);
				}
				for(k=0;k<blur_size;k++){ //kolejne 4 kolumny
					buf[rowsize*i+j+k*3+col]=sr[col]; // zmiana wartosci wierszy
					buf[rowsize*i+j+rowsize+k*3+col]=sr[col];
					buf[rowsize*i+j+2*rowsize+k*3+col]=sr[col];
					buf[rowsize*i+j+3*rowsize+k*3+col]=sr[col];
				}
			}
		}
	}
}

void HorizontalCopy3(unsigned char * pixels, int width, int height, int size, char bpp) {
	while(pixels){
		int i = 0;
		while(i++) {

		}
	}
	for(int x = 0; x < width; x++) {
		for(int y = 0 ; y < height; y++) {
		    unsigned char offset = ( width * y ) + x;
			unsigned char offset2 = ( width * (height - y) ) + (width - x);
			unsigned char tmp = pixels[offset];
			pixels[offset] = pixels[offset2];
			pixels[offset2] = tmp;
		}
	}		
}


void RandomFilter(unsigned char * pixels, int width, int height, int size, char bpp) {
	for( unsigned int i = 0; i < 1000; i++ ) {
		const unsigned int x = rand() % width;
		const unsigned int y = rand() % height;

		const unsigned int offset = ( width * 4 * y ) + x * 4;
		pixels[ offset + 0 ] = rand() % 256;        // b
		pixels[ offset + 1 ] = rand() % 256;        // g
		pixels[ offset + 2 ] = rand() % 256;        // r
		pixels[ offset + 3 ] = SDL_ALPHA_OPAQUE;    // a
	}
}



SDL_Surface* Load_image(char *file_name)
{
		/* Open the image file */
		SDL_Surface* tmp = IMG_Load(file_name);
		if ( tmp == NULL ) {
			fprintf(stderr, "Couldn't load %s: %s\n",
			        file_name, SDL_GetError());
				exit(0);
		}
		return tmp;	
}

void Paint(SDL_Surface* image, SDL_Surface* screen)
{
		SDL_BlitSurface(image, NULL, screen, NULL);
		SDL_UpdateRect(screen, 0, 0, 0, 0);
};



int main(int argc, char *argv[])
{
	Uint32 flags;
	SDL_Surface *screen, *image;
	int depth, done;
	SDL_Event event;

	/* Check command line usage */
	if ( ! argv[1] ) {
		fprintf(stderr, "Usage: %s <image_file>, (int) size\n", argv[0]);
		return(1);
	}

	if ( ! argv[2] ) {
		fprintf(stderr, "Usage: %s <image_file>, (int) size\n", argv[0]);
		return(1);
	}

	/* Initialize the SDL library */
	if ( SDL_Init(SDL_INIT_VIDEO) < 0 ) {
		fprintf(stderr, "Couldn't initialize SDL: %s\n",SDL_GetError());
		return(255);
	}

	flags = SDL_SWSURFACE;
	image = Load_image( argv[1] );
	printf( "\n\nImage properts:\n" );
	printf( "BitsPerPixel = %i \n", image->format->BitsPerPixel );
	printf( "BytesPerPixel = %i \n", image->format->BytesPerPixel );
	printf( "width %d ,height %d \n\n", image->w, image->h );	 	

	SDL_WM_SetCaption(argv[1], "showimage");

	/* Create a display for the image */
	depth = SDL_VideoModeOK(image->w, image->h, 32, flags);
	/* Use the deepest native mode, except that we emulate 32bpp
	   for viewing non-indexed images on 8bpp screens */
	if ( depth == 0 ) {
		if ( image->format->BytesPerPixel > 1 ) {
			depth = 32;
		} else {
			depth = 8;
		}
	} else
	if ( (image->format->BytesPerPixel > 1) && (depth == 8) ) {
    		depth = 32;
	}
	if(depth == 8)
		flags |= SDL_HWPALETTE;
	screen = SDL_SetVideoMode(image->w, image->h, depth, flags);
	if ( screen == NULL ) {
		fprintf(stderr,"Couldn't set %dx%dx%d video mode: %s\n",
			image->w, image->h, depth, SDL_GetError());
	}

	/* Set the palette, if one exists */
	if ( image->format->palette ) {
		SDL_SetColors(screen, image->format->palette->colors, 0, image->format->palette->ncolors);
	}


	/* Display the image */
	Paint(image, screen);

	done = 0;
	int size =atoi( argv[2] );
	printf("Actual size is: %d\n", size);
	while ( ! done ) {
		if ( SDL_PollEvent(&event) ) {
			switch (event.type) {
			    case SDL_KEYUP:
				switch (event.key.keysym.sym) {
				    case SDLK_ESCAPE:
				    case SDLK_TAB:
				    case SDLK_q:
						done = 1;
						break;
				    case SDLK_SPACE:
					case SDLK_1:
						SDL_LockSurface(image);
					
						printf("Start filtering...  ");
						RandomFilter(image->pixels, image->w, image->h,size,image->format->BytesPerPixel);
						printf("Done.\n");

						SDL_UnlockSurface(image);
						
						printf("Repainting after filtered...  ");
						Paint(image, screen);
						printf("Done.\n");
						break;
					case SDLK_2:
						SDL_LockSurface(image);					
						printf("Start filtering...  ");
						RandomFilter(image->pixels, image->w, image->h,size,image->format->BytesPerPixel);
						printf("Done.\n");

						SDL_UnlockSurface(image);
						
						printf("Repainting after filtered...  ");
						Paint(image, screen);
						printf("Done.\n");
						break;

					case SDLK_3:
						SDL_LockSurface(image);					
						printf("Start filtering...  ");
						RandomFilter(image->pixels, image->w, image->h,size,image->format->BytesPerPixel);
						printf("Done.\n");

						SDL_UnlockSurface(image);
						
						printf("Repainting after filtered...  ");
						Paint(image, screen);
						printf("Done.\n");
					break;


					
					case SDLK_f:
						SDL_LockSurface(image);
						
						printf("Start filtering...  ");
						Negative(image->pixels, image->w, image->h, size, image->format->BytesPerPixel );
						printf("Done.\n");

						SDL_UnlockSurface(image);
						
						printf("Repainting after filtered...  ");
						Paint(image, screen);
						printf("Done.\n");
						break;
				    case SDLK_r:
						printf("Reloading image...  ");
						image = Load_image( argv[1] );
						Paint(image,screen);
						printf("Done.\n");
						break;
				    case SDLK_PAGEDOWN:
				    case SDLK_DOWN:
				    case SDLK_KP_MINUS:
						size--;
						if (size==0) size--;
						printf("Actual size is: %d\n", size);
				        break;
				    case SDLK_PAGEUP:
				    case SDLK_UP:
				    case SDLK_KP_PLUS:
						size++;
						if (size==0) size++;
						printf("Actual size is: %d\n", size);
						break;		
				    case SDLK_s:
						printf("Saving surface at nowy.bmp ...");
						SDL_SaveBMP(image, "nowy.bmp" ); 
						printf("Done.\n");
				    default:
					break;
				}
				break;
//			    case  SDL_MOUSEBUTTONDOWN:
//				done = 1;
//				break;
                            case SDL_QUIT:
				done = 1;
				break;
			    default:
				break;
			}
		} else {
			SDL_Delay(10);
		}
	}
	SDL_FreeSurface(image);
	/* We're done! */
	SDL_Quit();
	return(0);
}

