import std.stdio;
import std.typecons;
import std.math;
import std.range;
import std.conv;

import gfm.core;
import gfm.sdl2;

double geometry_function(double x, double y) {
    return cos(x) + sin(y);
}

void main()
{
    int width = 1000;
    int height = 1000;
    // load dynamic libraries
    auto sdl2 = scoped!SDL2(null);

    // create an OpenGL-enabled SDL window
    auto window = scoped!SDL2Window(sdl2, 
                                    SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED,
                                    width, height,
                                    SDL_WINDOW_BORDERLESS);

    auto renderer = scoped!SDL2Renderer(window);
    auto offset = 2;
    auto size = 10;
    auto t = 0;
    auto factor = 1.0f;
    auto running = true;
    bool ascending = true;
    int stage = 0;
    while(running) {
        ++t;
        sdl2.processEvents();
        renderer.setColor(255, 255, 255, 0);
        if (stage == 0) {
            foreach (x; iota(0, width, size+offset)) {
                foreach(y; iota(0, height, size+offset)) {
                    renderer.drawRect((width) - (x + (width / 2)) - (size / 2),
                            (height) - (y + (height / 2)) - (size / 2),
                            size, size);
                    renderer.drawRect(x + (width / 2) - (size/ 2),
                            (height) - (y + (height / 2)) - (size/ 2),
                            size, size);
                    renderer.drawRect((width) - (x + (width / 2)) - (size / 2),
                            y + (height / 2) - (size / 2),
                            size, size);
                    renderer.drawRect(x + (width / 2) - (size / 2),
                            y + (height / 2) - (size / 2),
                            size, size);
                }
            }
            offset += 2;
            factor += t * 0.00001f;
            size = (width * abs(sin(t / 100.0f)) / factor).to!int + 10;
            if (factor > size * 5) {
                stage++;
                factor = 1.0f;
            }
        } else if (stage == 1) {
            int num_trails = 10;
            foreach(i; 1 .. num_trails) {
                if (i == factor) continue;
                float theta = t.to!float / ((factor * 25 )+ i);
                renderer.setColor(
                        ((i.to!float / num_trails) * 255).to!int,
                        ((i.to!float / num_trails) * 255).to!int,
                        ((i.to!float / num_trails) * 255).to!int,
                        0);
                foreach (r; iota(0, factor)) {
                    renderer.drawRect(
                            width - ((r * cos(theta + r)).to!int + width / 2) - (size/2),
                            height - ((r * sin(theta + r)).to!int + height / 2) - (size/2),
                            size, size);
                }
            }
            if (ascending && factor > sqrt(width.to!float * height.to!float)) {
                ascending = false;
            } else if (!ascending && factor < 10) {
                ascending = true;
            }

            if (ascending) {
                factor *= 1.003;
            } else {
                factor -= 4;
            }
            if (t > 12000){
                stage++;
            }
        } else {
            running = false;
        }

        renderer.present();
        renderer.setColor(0, 0, 0, 0);
        renderer.clear();

        if (sdl2.keyboard().isPressed(SDLK_ESCAPE)) {
            running = false;
        }
    }

}
