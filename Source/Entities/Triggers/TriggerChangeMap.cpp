#pragma once
#include "Leadwerks.h"
#include "TriggerChangeMap.h"

using namespace Leadwerks;

void TriggerChangeMap::Start()
{
    //Listen(EVENT_KEYDOWN, NULL);// makes this component listen for keydown events from all windows

	
    auto entity = GetEntity();
    world = entity->GetWorld();
    if (entity->GetCollisionType() == COLLISION_TRIGGER)
    {
        entity->SetRenderLayers(0);
        entity->SetShadows(false);
        entity->SetPickMode(PICK_NONE);
    }
}

void TriggerChangeMap::Update()
{
    
}

void TriggerChangeMap::Collide(shared_ptr<Entity> collidedentity, const Vec3& position, const Vec3& normal, const float speed)
{
	if (mapName != "" && enabled)
	{
		// Load the new map
        LoadScene(world, mapName);
	}
}

bool TriggerChangeMap::ProcessEvent(const Event& e)
{
    /*switch (e.id)
    {
    case EVENT_KEYDOWN:
        if (e.data == KEY_SPACE)
        {
            Print("Space key pressed");
        }
        break;
    }*/
    return true;
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