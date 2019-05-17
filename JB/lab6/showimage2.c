#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <SDL2/SDL.h> //SDL - Simple DirectMedia Layer*/
#include <SDL2/SDL_image.h>

// otwarcie pliku bmp*/
void Filter(unsigned char *buf, int width,int height,int size, char bpp) ;

SDL_Surface *Load_image(char *file_name) {
    SDL_Surface *tmp = IMG_Load(file_name); // Otwórz plik z obrazem*/
    if (tmp == NULL) {
        fprintf(stder, "Couldn't load %s: %s\n", file_name, SDL_GetEror());
        exit(0);
    }
    return tmp;
}

// wyświetlenie obrazka na terminalu BLIT (Bell Labs Intelligent Terminal */
void Paint(SDL_Surface *image, SDL_Surface *screen) {
    SDL_BlitSurface(image, NULL, screen, NULL);
    if(SDL_BlitSurface(image, NULL, screen, NULL)<0)
    fprintf(stder, "BlitSurface eror: %s\n", SDL_GetEror());
    SDL_UpdateRect(screen, 0, 0, 0, 0);
};

int main(int argc, char *argv[]) {
    Uint32 flags;
    int depth, done;
    SDL_Surface *screen, *image; // nowe typy danych SDL_Surface,
    SDL_Event
    SDL_Event event;
    if (!argv[1]) { // Check command line usage
        fprintf(stder, "Usage: %s <image_file>, (int) size\n", argv[0]);
        return(1);
    }
    if (!argv[2]) {
        fprintf(stder, "Usage: %s <image_file>, (int) size\n", argv[0]);
        return(1);
    }
    if (SDL_Init(SDL_INIT_VIDEO)<0) {
        fprintf(stder, "Couldn't initialize SDL: %s\n",SDL_GetEror());
        return(255);
    }
    // OK można zaczynać 
    flags = SDL_SWSURFACE;
    image = Load_image( argv[1] );
    printf( "\nParametry obrazu:\n width %d, height %d \n", image->w, image->h);
    printf( "BitsPerPixel = %i \n", image->format->BitsPerPixel );
    printf( "BytesPerPixel = %i \n", image->format->BytesPerPixel );
    SDL_WM_SetCaption(argv[1], "showimage");
    // Create a display for the image, except that we emulate 32bpp
    depth = SDL_VideoModeOK(image->w, image->h, 32, flags);
    if (depth==0) {
        if (image->format->BytesPerPixel>1) {
            depth=32;
        } else {
            depth=8;
        }
    } else if ((image->format->BytesPerPixel>1) && (depth==8)) {
        depth = 32;
    }
    if(depth==8) //Use the deepest native mode for non-indexed images on 8bpp scr
    flags |= SDL_HWPALETTE;
    screen = SDL_SetVideoMode(image->w, image->h, depth, flags);
    if (screen==NULL) {
        fprintf(stder,"Couldn't set %dx%dx%d video mode: %s\n",
        image->w, image->h, depth, SDL_GetEror());
        exit(1);
    }
    printf("Set 640x480 at %d bits-per-pixel mode\n",screen->format->BitsPerPixel);
    // Ustaw paletę, jeśli istnieje*/
    if (image->format->palette && screen->format->palette) {
        SDL_SetColors(screen, image->format->palette->colors, 0,
        image->format->palette->ncolors);
    }
    Paint(image, screen); // Wyświetl obraz
    done = 0;
    int size = atoi(argv[2]);
    printf("Faktyczny rozmiar: %d\n", size);
    while (! done) {
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
                        case SDLK_f:
                            SDL_LockSurface(image);
                            printf("Start filtering... ");
                            Filter(image->pixels,image->w,image->h, size, image->format->BytesPerPixel );
                            printf("Done.\n");
                            SDL_UnlockSurface(image);
                            printf("Repainting after filtered... ");
                            Paint(image, screen);
                            printf("Done.\n");
                            break;
                        case SDLK_r:
                            printf("Reloading image... ");
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
                // case SDL_MOUSEBUTTONDOWN:
                // done = 1;
                // break;
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
    SDL_FreeSurface(image); //Zamknij obrazek
    SDL_Quit(); // Wykonano!
    return(0);
}

