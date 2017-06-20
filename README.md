# Swarm of UAVs
[![yt-video](https://cloud.githubusercontent.com/assets/9435724/13357897/8df83810-dca4-11e5-8fb0-018e99a5c139.png)](https://www.youtube.com/watch?v=qWS4iV0g2EE)

## Description
Simulation for behaviour of a swarm of UAVs for tracking a pollutant cloud.

Initially one UAV flies in a spiral trying to find a cloud and once it finds it, it calls more UAVs to fly around the cloud and track the cloud's border corresponding to a pollutant concentration of 1.0. The goal is to have the UAVs uniformly spread around the cloud.

Each UAV can fly for 30 minutes after which it needs to go back to the base (0,0) to recharge.

#### `sim-start.m`
This file performs the setup of the simulation and starts it.
#### `uav-fsm.m`
Contains the Finite State Machine that controls the behaviour of the UAV.
#### `update-location.m`
Models the movement of the UAV using Runge–Kutta method.

## Method
For spreading uniformly around the cloud the UAVs calculate the Convex Hull of the cloud (based on the sampled points) and speed up/slow down based on the location of the other UAVs.

If the perimeter of the cloud gets too big, a new UAV is called to fly around the cloud

#### Collision Avoidance
To achieve this I modelled each UAV to be an electron and each UAV applies a repelling force on all the other UAVs (that are close enough).
