#pragma once
#include "Leadwerks.h"

using namespace Leadwerks;

class SlidingDoor : public Component//Component
{
    shared_ptr<Joint> joint;
    Vec3 startposition;
    float storedmass = 0.0f;
    bool fullyopened = false;
    bool fullyclosed = false;

    void BuildJoint();

public:
    bool openstate = false;//"Start open"
    Vec3 movement = Vec3(0, 1.28, 0);
    float speed = 100.0f;//"Speed"
    float maxforce = 1000;//"Max force"
	
	/*
	Vec3 movement = Vec3(0, 128, 0);//"Movement"
	bool enabled = true;//"Enabled"
	virtual void Enable();//inout
	*/
	
    float distancetolerance = 0.1f;
    bool relativemovement = false;
    //bool togglemass = true;
    
    SlidingDoor();

    virtual void Start();
    virtual void Update();
    virtual void Open();//inout
    virtual void Close();//inout
    virtual void ToggleDoor();
    virtual void Disable();//inout
    virtual void Enable();//inout
    virtual void Toggle();
    virtual void Use(shared_ptr<Entity> user);
    virtual bool Load(table& properties, shared_ptr<Stream> binstream, shared_ptr<Scene> scene, const LoadFlags flags, shared_ptr<Object> extra);
    virtual bool Save(table& properties, shared_ptr<Stream> binstream, shared_ptr<Scene> scene, const SaveFlags flags, shared_ptr<Object> extra);
    virtual std::any CallMethod(shared_ptr<Component> caller, const WString& name, const std::vector<std::any>& args);
    virtual std::shared_ptr<Component> Copy();
};