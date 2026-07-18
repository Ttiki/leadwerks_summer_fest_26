#pragma once
#include "Leadwerks.h"
#include "../BaseComponent.h"

using namespace Leadwerks;

class Mover : public BaseComponent//Component
{
public: 
    Vec3 movementspeed = Vec3(0,0,0);//"Movement speed"
    Vec3 rotationspeed = Vec3(0,1,0);//"Rotation speed"
    bool globalcoords = false;//"World space"
	
    Mover();
    virtual void Update();
    virtual bool Load(table& properties, shared_ptr<Stream> binstream, shared_ptr<Scene> scene, const LoadFlags flags, shared_ptr<Object> extra);
    virtual bool Save(table& properties, shared_ptr<Stream> binstream, shared_ptr<Scene> scene, const SaveFlags flags, shared_ptr<Object> extra);
    virtual std::shared_ptr<Component> Copy();
};