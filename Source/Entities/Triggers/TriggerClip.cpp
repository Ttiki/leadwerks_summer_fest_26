#pragma once
#include "Leadwerks.h"
#include "TriggerClip.h"

using namespace Leadwerks;

void TriggerClip::Start()
{
    auto entity = GetEntity();
	entity->SetRenderLayers(0);
	entity->SetShadows(false);
    entity->SetPickMode(PICK_NONE);
    
}