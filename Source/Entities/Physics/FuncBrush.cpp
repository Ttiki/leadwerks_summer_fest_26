#pragma once
#include "Leadwerks.h"
#include "FuncBrush.h"

using namespace Leadwerks;

void FuncBrush::Start()
{
    //Listen(EVENT_KEYDOWN, NULL);// makes this component listen for keydown events from all windows
	auto entity = GetEntity();
    switch (collisionMode)
    {
    case 0:
        entity->SetCollisionType(COLLISION_SCENE);
        break;
    case 1:
        entity->SetCollisionType(COLLISION_NONE);
        break;
    }

    if (enabled)
    {
		entity->SetRenderLayers(1);
		entity->SetPickMode(PICK_MESH);
		entity->SetShadows(true);
        entity->SetHidden(false);
    }else
    {
        entity->SetShadows(false);
		entity->SetPickMode(PICK_NONE);
        entity->SetHidden(true);
    }
}

void FuncBrush::ToggleCollision()
{
	auto entity = GetEntity();
	if (collisionMode == 0)
	{
		collisionMode = 1;
		entity->SetCollisionType(COLLISION_NONE);
	}
	else
	{
		collisionMode = 0;
		entity->SetCollisionType(COLLISION_SCENE);
	}
}


bool FuncBrush::Load(table& properties, shared_ptr<Stream> binstream, shared_ptr<Scene> scene, const LoadFlags flags, std::shared_ptr<Object> extra)
{
    if (properties["collisionMode"].is_number()) collisionMode = properties["collisionMode"];
    if (properties["enabled"].is_number()) enabled = properties["enabled"];
	//Trim the color string and split it into three parts
	if (properties["color"].is_string())
	{
		std::string colorString = properties["color"];
		std::vector<std::string> colorParts;
		size_t pos = 0;
		while ((pos = colorString.find(",")) != std::string::npos) {
			colorParts.push_back(colorString.substr(0, pos));
			colorString.erase(0, pos + 1);
		}
		colorParts.push_back(colorString);
		if (colorParts.size() == 3)
		{
			color.x = std::stof(colorParts[0]);
			color.y = std::stof(colorParts[1]);
			color.z = std::stof(colorParts[2]);
		}
	}

    return BaseComponent::Load(properties, binstream, scene, flags, extra);
}

bool FuncBrush::Save(table& properties, shared_ptr<Stream> binstream, shared_ptr<Scene> scene, const SaveFlags flags, std::shared_ptr<Object> extra)
{
    properties["collisionMode"] = collisionMode;
    properties["enabled"] = enabled;
    //Convert color to string
	properties["color"] = std::to_string(color.x) + "," + std::to_string(color.y) + "," + std::to_string(color.z);
    return BaseComponent::Save(properties, binstream, scene, flags, extra);
}

//This method will work with simple components
shared_ptr<Component> FuncBrush::Copy()
{
    return std::make_shared<FuncBrush>(*this);
}

std::any FuncBrush::CallMethod(shared_ptr<Component> sender, const WString& name, const std::vector<std::any>& arguments)
{
    /*if (name == "MyMethod")
    {
        MyMethod();
        return false;
    }*/
    return BaseComponent::CallMethod(sender, name, arguments);
}