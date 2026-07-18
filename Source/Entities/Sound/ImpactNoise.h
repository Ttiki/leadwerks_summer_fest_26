#pragma once
#include "Leadwerks.h"
#include "../BaseComponent.h"

using namespace Leadwerks;

class ImpactNoise : public BaseComponent//Component
{
public:
    inline static uint64_t lastplaytime = 0;
    std::vector<shared_ptr<Sound> > sounds;
    const int MaxSounds = 3;
    float minspeed = 2.0f;
    float range = 10.0f;// "Range"
    Vec3 force;// "Force"

    ImpactNoise();

    virtual void ApplyForce();//in
    virtual void Collide(std::shared_ptr<Entity> collidedentity, const Vec3& position, const Vec3& normal, const float speed);
	virtual bool Load(table& properties, std::shared_ptr<Stream> binstream, std::shared_ptr<Scene> scene, const LoadFlags flags, std::shared_ptr<Object> extra);
    virtual bool Save(table& properties, std::shared_ptr<Stream> binstream, std::shared_ptr<Scene> scene, const SaveFlags flags, std::shared_ptr<Object> extra);
    virtual std::shared_ptr<Component> Copy();
    virtual std::any CallMethod(shared_ptr<Component> sender, const WString& name, const std::vector<std::any>& arguments);
};