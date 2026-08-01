#pragma once
#include "Leadwerks.h"
#include "../BaseComponent.h"
#include "CollisionTrigger.h"

using namespace Leadwerks;

class TriggerTeleport : public CollisionTrigger//Component
{
public: 
    bool bEnabled = true;//"Enabled"
    bool bOnlyOnce = false;//"Only Once"

    std::shared_ptr<Entity> entityvalue;//"Entity value"
	bool bKeepRot = false;//"Keep Rotation"

    virtual void Collide(std::shared_ptr<Entity> collidedentity, const Vec3& position, const Vec3& normal, const float speed);
	virtual bool Load(table& properties, std::shared_ptr<Stream> binstream, std::shared_ptr<Scene> scene, const LoadFlags flags, std::shared_ptr<Object> extra);
    virtual bool Save(table& properties, std::shared_ptr<Stream> binstream, std::shared_ptr<Scene> scene, const SaveFlags flags, std::shared_ptr<Object> extra);
    virtual std::shared_ptr<Component> Copy();
    virtual std::any CallMethod(shared_ptr<Component> sender, const WString& name, const std::vector<std::any>& arguments);
};