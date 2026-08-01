#pragma once
#include "Leadwerks.h"
#include "TriggerChangeMap.h"

using namespace Leadwerks;

void TriggerChangeMap::Start()
{
    //Listen(EVENT_KEYDOWN, NULL);// makes this component listen for keydown events from all windows

	
    auto entity = GetEntity();
    
    if (entity->GetCollisionType() == COLLISION_TRIGGER)
    {
        entity->SetRenderLayers(0);
        entity->SetShadows(false);
        entity->SetPickMode(PICK_NONE);
    }
}



void TriggerChangeMap::Collide(shared_ptr<Entity> collidedentity, const Vec3& position, const Vec3& normal, const float speed)
{
	if (mapName.empty() && enabled)
	{
        auto entity = GetEntity();
		// Load the new map
        LoadScene(entity->GetWorld(), "Maps/" + mapName);
	}
}



//This method will work with simple components
shared_ptr<Component> TriggerChangeMap::Copy()
{
    return std::make_shared<TriggerChangeMap>(*this);
}

std::any TriggerChangeMap::CallMethod(shared_ptr<Component> sender, const WString& name, const std::vector<std::any>& arguments)
{
    /*if (name == "MyMethod")
    {
        MyMethod();
        return false;
    }*/
    return BaseComponent::CallMethod(sender, name, arguments);
}