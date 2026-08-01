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
    Print(mapName);
}



void TriggerChangeMap::Collide(shared_ptr<Entity> collidedentity, const Vec3& position, const Vec3& normal, const float speed)
{
    if (ChangeMap()) { Print("Map changed successfully."); }
    else { Print("Failed to change map."); }
}

bool TriggerChangeMap::ChangeMap()
{
	if (mapName != "" && enabled)
	{
		auto entity = GetEntity();
		// Load the new map
		String concatMapName = "Maps/" + mapName + ".map";
		Print("Loading map: " + concatMapName);
		LoadScene(entity->GetWorld(), concatMapName);
        return true;
	}
    return false;
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