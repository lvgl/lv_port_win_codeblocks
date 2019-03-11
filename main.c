
/**
 * @file main
 *
 */

/*********************
 *      INCLUDES
 *********************/
#include <stdlib.h>
#include <unistd.h>

#include "lvgl/lvgl.h"
#include "lv_drivers/win_drv.h"
#include "lv_examples/lv_apps/demo/demo.h"
#include "lv_examples/lv_apps/benchmark/benchmark.h"
#include "lv_examples/lv_tests/lv_test_theme/lv_test_theme_1.h"
#if WIN32
#include <windows.h>
#else
#include <SDL2/SDL.h>
#endif

/*********************
 *      DEFINES
 *********************/

/**********************
 *      TYPEDEFS
 **********************/

/**********************
 *  STATIC PROTOTYPES
 **********************/
static void hal_init(void);
static int tick_thread(void *data);

/**********************
 *  STATIC VARIABLES
 **********************/

/**********************
 *      MACROS
 **********************/

/**********************
 *   GLOBAL FUNCTIONS
 **********************/
#if WIN32
int APIENTRY WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR szCmdLine, int nCmdShow)
#else
int main(int argc, char** argv)
#endif // WIN32
{
    /*Initialize LittlevGL*/
    lv_init();

    /*Initialize the HAL for LittlevGL*/
    hal_init();

    /*Load a demo*/
    //demo_create();

    /*Try the benchmark to see how fast is your GUI*/
    //benchmark_create();

    //sysmon_create();
    //terminal_create();
    //tpcal_create();

    /*Check the themes too*/
    lv_disp_set_default(lv_windows_disp);
    //demo_create();
    lv_test_theme_1(lv_theme_default_init(210, NULL));
#if WIN32
    while(!lv_win_exit_flag) {
#else
    while(1) {
#endif // WIN32
        /* Periodically call the lv_task handler.
         * It could be done in a timer interrupt or an OS task too.*/
        lv_task_handler();
        usleep(1000);       /*Just to let the system breath*/
    }
    return 0;
}

/**********************
 *   STATIC FUNCTIONS
 **********************/

/**
 * Initialize the Hardware Abstraction Layer (HAL) for the Littlev graphics library
 */
static void hal_init(void)
{
#if !WIN32
    /* Add a display
     * Use the 'monitor' driver which creates window on PC's monitor to simulate a display*/
    monitor_init();
    lv_disp_drv_t disp_drv;
    lv_disp_drv_init(&disp_drv);            /*Basic initialization*/
    disp_drv.disp_flush = monitor_flush;
    disp_drv.disp_fill = monitor_fill;
    disp_drv.disp_map = monitor_map;
    lv_disp_drv_register(&disp_drv);

    /* Add the mouse (or touchpad) as input device
     * Use the 'mouse' driver which reads the PC's mouse*/
    mouse_init();
    lv_indev_drv_t indev_drv;
    lv_indev_drv_init(&indev_drv);          /*Basic initialization*/
    indev_drv.type = LV_INDEV_TYPE_POINTER;
    indev_drv.read = mouse_read;         /*This function will be called periodically (by the library) to get the mouse position and state*/
    lv_indev_drv_register(&indev_drv);

    /* Tick init.
     * You have to call 'lv_tick_handler()' in every milliseconds
     * Create an SDL thread to do this*/
    SDL_CreateThread(tick_thread, "tick", NULL);
#else
    /* This sets up some timers to handle everything. */
    windrv_init();
#endif
}
#if !WIN32
/**
 * A task to measure the elapsed time for LittlevGL
 * @param data unused
 * @return never return
 */
static int tick_thread(void *data)
{
    while(1) {
        lv_tick_inc(1);
        SDL_Delay(1);   /*Sleep for 1 millisecond*/
    }

    return 0;
}
#endif
