#pragma once
#include "Leadwerks.h"

// This file was automatically generated

#include "Entities/AI/Monster.h"
#include "Entities/Appearance/ChangeEmission.h"
#include "Entities/Appearance/ChangeVisibility.h"
#include "Entities/Logic/MultiRelay.h"
#include "Entities/Logic/Relay.h"
#include "Entities/Motion/Mover.h"
#include "Entities/Physics/SlidingDoor.h"
#include "Entities/Physics/SwingingDoor.h"
#include "Entities/Player/CameraControls.h"
#include "Entities/Player/FPSPlayer.h"
#include "Entities/Player/VRPlayer.h"
#include "Entities/Sound/AmbientNoise.h"
#include "Entities/Sound/ImpactNoise.h"
#include "Entities/Triggers/CollisionTrigger.h"
#include "Entities/Triggers/PushButton.h"
#include "Entities/Weapons/Bullet.h"
#include "Entities/Weapons/FPSGun.h"

void RegisterComponents()
{
	RegisterComponent<Monster>();
	RegisterComponent<ChangeEmission>();
	RegisterComponent<ChangeVisibility>();
	RegisterComponent<MultiRelay>();
	RegisterComponent<Relay>();
	RegisterComponent<Mover>();
	RegisterComponent<SlidingDoor>();
	RegisterComponent<SwingingDoor>();
	RegisterComponent<CameraControls>();
	RegisterComponent<FPSPlayer>();
	RegisterComponent<VRPlayer>();
	RegisterComponent<AmbientNoise>();
	RegisterComponent<ImpactNoise>();
	RegisterComponent<CollisionTrigger>();
	RegisterComponent<PushButton>();
	RegisterComponent<Bullet>();
	RegisterComponent<FPSGun>();
}
