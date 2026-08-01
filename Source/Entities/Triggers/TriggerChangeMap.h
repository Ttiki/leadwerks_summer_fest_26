#pragma once
#include "Leadwerks.h"
#include "../BaseComponent.h"

using namespace Leadwerks;

class TriggerChangeMap : public BaseComponent//Component
{
public: 
    WString mapName = "";//"Map name"
    bool enabled = true;//"Enabled"
	
	static shared_ptr<World> world;

    virtual void Start();

    virtual void Collide(std::shared_ptr<Entity> collidedentity, const Vec3& position, const Vec3& normal, const float speed);
	virtual bool Load(table& properties, std::shared_ptr<Stream> binstream, std::shared_ptr<Scene> scene, const LoadFlags flags, std::shared_ptr<Object> extra);
    virtual bool Save(table& properties, std::shared_ptr<Stream> binstream, std::shared_ptr<Scene> scene, const SaveFlags flags, std::shared_ptr<Object> extra);
    virtual std::shared_ptr<Component> Copy();
    virtual std::any CallMethod(shared_ptr<Component> sender, const WString& name, const std::vector<std::any>& arguments);
};