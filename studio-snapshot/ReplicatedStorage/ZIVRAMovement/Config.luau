-- All motion tunables live here. Animation IDs must belong to the experience owner.
return {
 WalkSpeed=16, SprintSpeed=25, CrouchSpeed=8, Acceleration=85, Deceleration=110,
 JumpPower=48, SlideSpeed=34, SlideEndSpeed=18, SlideDuration=0.72,
 SlideCooldown=0.85, SlideSteering=2.5, SlideJumpSpeed=29, AirSpeedCap=31,
 SlideCameraDrop=1.05, CrouchCameraDrop=0.65, BaseFOV=74, SprintFOV=81,
 CameraSmooth=15, CameraBob=0.035, CameraRoll=0.65, MotionScale=1,
 AutoSprint=false, AnimationFade=0.12, AnimationSpeed=1,
 SprintKeys={Enum.KeyCode.LeftShift,Enum.KeyCode.ButtonL3},
 SlideKeys={Enum.KeyCode.LeftControl,Enum.KeyCode.C,Enum.KeyCode.ButtonB},
 CrouchKeys={Enum.KeyCode.X}, AutoSprintKey=Enum.KeyCode.T,
 -- Optional published replacements; blank uses original procedural poses.
 AnimationIds={Sprint='rbxassetid://95117441928166', Slide='rbxassetid://118788201652357'},
}