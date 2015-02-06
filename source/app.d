import std.stdio;
import std.typecons;
import std.math;
import std.range;
import std.conv;
import std.random;

import gfm.core;
import gfm.sdl2;

void drawBillboard(SDL2Renderer renderer, string[] billboard, int x, int y, int size) {
    foreach (dy, row; billboard) {
        foreach (dx, col; row) {
            if (col == 'x') {
                renderer.fillRect(
                        x + (( dx) * size).to!int,
                        y + ((dy) * size).to!int,
                        size, size);
            }
        }
    }
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
    auto t_s = 0; // time into the step
    auto factor = 1.0f;
    auto running = true;
    bool ascending = true;
    int stage = 1;
    while(running) {
        ++t;
        ++t_s;
        sdl2.processEvents();
        renderer.setColor(255, 255, 255, 0);
        if (stage == 0) {
            auto ticks_to_load = 1000;
            {
                // Draw the backing for the loading bar
                renderer.setColor(255, 255, 255);
                auto low_x = width / 10;
                auto h = height / 10;
                renderer.fillRect(low_x, width / 2 - h / 2, width * 8 / 10,  h);
            }
            {
                // Draw the "loading" bar
                renderer.setColor(0, 255, 0);
                auto low_x = width / 10;
                auto w = width * 8 / 10 * t_s/ ticks_to_load;
                auto h = height / 10;
                renderer.fillRect(low_x, width / 2 - h / 2, w.to!int, h);
            }
            {
                // Draw some sexy text
                auto billboard = [
                    ".........................................",
                    "..x....xx...xx..xxx..xxx.x..x..xxx.......",
                    "..x...x..x.x..x.x..x..x..xx.x.x..........",
                    "..x...x..x.x..x.x..x..x..xx.x.x..........",
                    "..x...x..x.xxxx.x..x..x..x.xx.x.xx.......",
                    "..x...x..x.x..x.x..x..x..x.xx.x..x.......",
                    "..xxx..xx..x..x.xxx..xxx.x..x..xxx.x.x.x.",
                    ".........................................",
                    ];
                renderer.setColor(0, 128, 0);
                size = 10;
                auto x = (width / 2 - billboard[0].length.to!int * size/ 2).to!int;
                auto y = (height / 2 - billboard.length.to!int * size/ 2).to!int;
                renderer.drawBillboard(billboard, x, y, size);
            }
            {
                // Draw a logo thing
                auto billboard = [
                    //TionAnima
                    "                                                           ",
                    "                                                           ",
                    "               x                             x             ",
                    "       xxxxxxxx               x             x x            ",
                    "      x   xx                 x x             x         x x ",
                    "          xx                 x x                        x  ",
                    "          xx      x          x x                       x x ",
                    "          xx     x x        x   x                          ",
                    "          xx      x         x   x         x x              ",
                    "          xx                x   x          x               ",
                    "     x x  xx                x   x         x x              ",
                    "      x   xx               x     x                         ",
                    "     x x  xx               xxxxxxx                         ",
                    "          xx  x            x     x        x                ",
                    "   x      xx     xx  xxx   x     x  xxx     xxx xx   xx    ",
                    "  x x     xx  x x  x x  x  x     x  x  x  x x  x  x x  x   ",
                    "   x      xx  x x  x x  x x       x x  x  x x  x  x x  x   ",
                    "          xx  x x  x x  x x       x x  x  x x  x  x x xx   ",
                    "          xx x   xx  x  x x       x x  x x  x  x  x xx x   ",
                    "                                                           ",
                    ];
                renderer.setColor(
                        t_s * 255 / ticks_to_load,
                        (sin(t_s / 40.0) * 128).to!int + 127,
                        (cos(t_s / 40.0) * 128).to!int + 127
                        );
                renderer.drawBillboard(billboard,
                        width / 2 - billboard[0].length.to!int * size / 2,
                        height / 2 - billboard.length.to!int * size * 3 / 2, size);
            }
            if (t_s >= ticks_to_load) {
                stage++;
                t_s = 0;
            }
        } else if (stage == 1) {
            if (t_s / 200 % 2 == 0) {
                renderer.setColor(255, 255, 255);
            } else {
                renderer.setColor(0, 0, 0);
            }
            renderer.fillRect(width / 2 - size,
                              height / 2 - size,
                              size, size);
            if (t_s > 1000) {
                stage++;
                t_s = 0;
            }
        } else if (stage == 2) {
            renderer.setColor(255, 255, 255);
            renderer.fillRect(width / 2 - size,
                              height / 2 - size,
                              size, size);
            auto rand = Random(0);
            foreach (y; iota(0, height + size, size)) {
                foreach (x; iota(0, width + size, size)) {
                    renderer.setColor(255 - t_s, 255 - t_s, 255 - t_s);
                    auto r1 = (uniform!"[]"(0, size/2, rand) * 2).to!int;
                    renderer.fillRect(x, y - r1, size, t_s / 10);
                }
            }
            if (t_s >= 255) {
                stage++;
                t_s = 0;
            }
        } else if (stage == 3) {
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
            factor += t_s * 0.00001f;
            size = (width * abs(sin(t / 100.0f)) / factor).to!int + 10;
            if (factor > size * 5) {
                stage++;
                t_s = 0;
                factor = 3.0f;
            }
        } else if (stage == 4) {
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
        } else if (stage == 5) {
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
        } else if (stage == 6) {
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
        } else if (stage == 7) {
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
                size = 8;
            }
        } else if (stage == 8) {
            foreach (y; iota(0, height, size)) {
                foreach (x; iota(0, width, size)) {
                    auto color = (x + t_s * 60) % (y + 1);
                    renderer.setColor(color % 127, color % 63, color, 0);
                    renderer.fillRect(x, y, size, size);
                }
            }
            if (t_s > 100) {
                stage++;
                t_s = 0;
            }
        } else if (stage == 9) {
            renderer.setColor(255, 255, 255);
            foreach (x; iota(0, width)) {
                auto dx = 0.0f;
                foreach (i; 1 .. 64) {
                    dx += cos(x / (3.0f * i) + t_s / 10.0f);
                }
                renderer.drawLine(x, height / 2 + (dx * 10).to!int,
                        x, height/2
                        );
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
