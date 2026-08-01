#pragma once
#include "Leadwerks.h"
#include "TriggerTeleport.h"

using namespace Leadwerks;


void TriggerTeleport::Collide(shared_ptr<Entity> collidedentity, const Vec3& position, const Vec3& normal, const float speed)
{
	collidedentity->SetPosition(entityvalue->GetPosition(false));
	if (!bKeepRot) collidedentity->SetRotation(entityvalue->GetRotation(true));
}

bool TriggerTeleport::Load(table& properties, shared_ptr<Stream> binstream, shared_ptr<Scene> scene, const LoadFlags flags, std::shared_ptr<Object> extra)
{
    if (properties["bEnabled"].is_number()) bEnabled = properties["bEnabled"];
    if (properties["bOnlyOnce"].is_boolean()) bOnlyOnce = properties["bOnlyOnce"];
    if (properties["entityvalue"].is_string())
    {
        entityvalue = scene->GetEntity(std::string(properties["entityvalue"]));
    }
    return CollisionTrigger::Load(properties, binstream, scene, flags, extra);
}

bool TriggerTeleport::Save(table& properties, shared_ptr<Stream> binstream, shared_ptr<Scene> scene, const SaveFlags flags, std::shared_ptr<Object> extra)
{
    properties["bEnabled"] = bEnabled;
    properties["bOnlyOnce"] = bOnlyOnce;
    if (entityvalue) properties["entityvalue"] = std::string(entityvalue->GetUuid());
    return CollisionTrigger::Save(properties, binstream, scene, flags, extra);
}

//This method will work with simple components
shared_ptr<Component> TriggerTeleport::Copy()
{
    return std::make_shared<TriggerTeleport>(*this);
}

std::any TriggerTeleport::CallMethod(shared_ptr<Component> sender, const WString& name, const std::vector<std::any>& arguments)
{
    /*if (name == "MyMethod")
    {
        MyMethod();
        return false;
    }*/
    return CollisionTrigger::CallMethod(sender, name, arguments);
}