//The minimum for glide_size to be clamped to.
//Clamped to 5 because byond's glide size scaling is actually just completely broken and "step"
//movement is better than dealing with the awful camera juddering
#define MIN_GLIDE_SIZE 4
//The maximum for glide_size to be clamped to.
//This shouldn't be higher than the icon size, and generally you shouldn't be changing this, but it's here just in case.
#define MAX_GLIDE_SIZE 8

//This is a global so it can be changed in game, if you want to make this a bit faster you can make it a constant/define directly in the code
//GLOBAL_VAR_INIT(glide_size_multiplier, 1.25)

GLOBAL_VAR_INIT(glide_size_multiplier, 1.0)

///Broken down, here's what this does:
/// divides the world icon_size (32) by delay divided by ticklag to get the number of pixels something should be moving each tick.
/// The division result is given a min value of 1 to prevent obscenely slow glide sizes from being set
/// Then that's multiplied by the global glide size multiplier. 1.25 by default feels pretty close to spot on. This is just to try to get byond to behave.
/// The whole result is then clamped to within the range above.
/// Not very readable but it works
#define DELAY_TO_GLIDE_SIZE(delay) (clamp(((world.icon_size / max((delay) / world.tick_lag, 1)) * GLOB.glide_size_multiplier), MIN_GLIDE_SIZE, MAX_GLIDE_SIZE))

///Similar to DELAY_TO_GLIDE_SIZE, except without the clamping, and it supports piping in an unrelated scalar
#define MOVEMENT_ADJUSTED_GLIDE_SIZE(delay, movement_disparity) (world.icon_size / ((delay) / world.tick_lag) * movement_disparity * GLOB.glide_size_multiplier)

//Movement loop priority. Only one loop can run at a time, this dictates that
// Higher numbers beat lower numbers
///Standard, go lower then this if you want to override, higher otherwise
#define MOVEMENT_DEFAULT_PRIORITY 10
///Very few things should override this
#define MOVEMENT_SPACE_PRIORITY 100
///Higher then the heavens
#define MOVEMENT_ABOVE_SPACE_PRIORITY (MOVEMENT_SPACE_PRIORITY + 1)

//Movement loop flags
///Should the loop act immediately following its addition?
#define MOVEMENT_LOOP_START_FAST (1<<0)
///Do we not use the priority system?
#define MOVEMENT_LOOP_IGNORE_PRIORITY (1<<1)
