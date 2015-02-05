import std.stdio;
import std.typecons;
import std.math;
import std.range;
import std.conv;
import std.random;

import gfm.core;
import gfm.sdl2;

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
    auto t_s = 0; // time into the step
    auto factor = 1.0f;
    auto running = true;
    bool ascending = true;
    int stage = 5;
    while(running) {
        ++t;
        ++t_s;
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
                t_s = 0;
                factor = 3.0f;
            }
        } else if (stage == 1) {
            int num_trails = 10;
            foreach(i; 1 .. num_trails) {
                if (i == factor) continue;
                float theta = t.to!float / ((factor * 25 )+ i);
                foreach (r; iota(0, factor)) {
                    renderer.setColor(
                            ((i.to!float / num_trails) * 255 * (r % 2 + 1)).to!int,
                            ((i.to!float / num_trails) * 255 * (r % 3 + 1)).to!int,
                            ((i.to!float / num_trails) * 255 * (r % 4 + 1)).to!int,
                            0);
                    renderer.drawRect(
                            width - ((r * cos(theta + r)).to!int + width / 2) - (size/2),
                            height - ((r * sin(theta + r)).to!int + height / 2) - (size/2),
                            size, size);
                }
            }
            if (ascending && factor > sqrt(width.to!float * height.to!float)) {
                ascending = false;
            } else if (!ascending && factor < 10) {
                stage++;
                t_s = 0;
            }

            if (ascending) {
                factor *= 1.003;
            } else {
                factor -= 4;
            }
        } else if (stage == 2) {
            foreach (k; 1 .. 10) {
                foreach (i; 0 .. 100) {
                    renderer.setColor(i, k, i);
                    auto x = ((t - i + k * 100) % width);
                    auto y = height / 2 + (sin((t - i) / 100.0) * height / k).to!int;
                    renderer.fillRect(x, y, 20, 20);
                    renderer.fillRect(width - x, y, 20, 20);
                    renderer.fillRect(x, height - y, 20, 20);
                    renderer.fillRect(width - x, height - y, 20, 20);
                }
            }
            if (t_s > 1000) {
                stage++;
                t_s = 0;
            }
        } else if (stage == 3) {
            foreach (k; 1 .. 10) {
                foreach (i; 0 .. 100) {
                    renderer.setColor(20 - i, k, i);
                    auto x = ((t - i + k * 100) * t_s % width);
                    auto y = height / 2 +
                        (
                         sin((t - i) / 100.0) * height / k
                         / (t_s * t_s / 20.0f)
                        ).to!int;
                    renderer.fillRect(x, y, 20, 20);
                    renderer.fillRect(width - x, y, 20, 20);
                    renderer.fillRect(x, height - y, 20, 20);
                    renderer.fillRect(width - x, height - y, 20, 20);
                }
            }
            if (t_s > 100) {
                stage++;
                t_s = 0;
                size = 20;
            }
        } else if (stage == 4) {
            factor = 10;
                    renderer.setColor(255, 10, 100);
                renderer.fillRect(
                        (t_s * factor).to!int,
                        height / 2 - size / t_s / 2,
                        (width - (t_s * factor) * 2).to!int,
                        size / t_s
                        );
            if (t_s * factor >= width / 2) {
                stage++;
                t_s = 0;
                size = 10000;
            }
        } else if (stage == 5) {
            foreach (y; iota(0, height + size, size)) {
                foreach (x; iota(0, width + size, size)) {
                    auto color = (x + t_s * 100) % (y + 1);
                    renderer.setColor(color, color, color, 0);
                    renderer.fillRect(x, y, size, size);
                }
            }
            if (t_s % 10 == 0 && size > 4)
                size--;
        
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
