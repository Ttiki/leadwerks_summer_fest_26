#pragma once
#include "Leadwerks.h"
#include "../BaseComponent.h"

using namespace Leadwerks;

class MathCounter : public BaseComponent//Component
{
public: 
    int beginValue = 0;//"Begin value"
    int addedValue = 0.0f;//"Added value"
    bool enabled = true;//"Enabled"

    virtual void Start();
    
    virtual int Add();
	virtual int Subtract();
    virtual int Reset();

	virtual bool Load(table& properties, std::shared_ptr<Stream> binstream, std::shared_ptr<Scene> scene, const LoadFlags flags, std::shared_ptr<Object> extra);
    virtual bool Save(table& properties, std::shared_ptr<Stream> binstream, std::shared_ptr<Scene> scene, const SaveFlags flags, std::shared_ptr<Object> extra);
    virtual std::shared_ptr<Component> Copy();
    virtual std::any CallMethod(shared_ptr<Component> sender, const WString& name, const std::vector<std::any>& arguments);

protected:
    int value;
};