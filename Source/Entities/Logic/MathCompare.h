#pragma once
#include "Leadwerks.h"
#include "../BaseComponent.h"

using namespace Leadwerks;

class MathCompare : public BaseComponent//Component
{
public: 
    int testValue = 0;//"Test value"
	int test = 0;//"Test value" ["<", ">", "="]
    bool enabled = true;//"Enabled"

    virtual void Start();
    
    virtual void Test(const int value2Test);//inout

	virtual bool Load(table& properties, std::shared_ptr<Stream> binstream, std::shared_ptr<Scene> scene, const LoadFlags flags, std::shared_ptr<Object> extra);
    virtual bool Save(table& properties, std::shared_ptr<Stream> binstream, std::shared_ptr<Scene> scene, const SaveFlags flags, std::shared_ptr<Object> extra);
    virtual std::shared_ptr<Component> Copy();
    virtual std::any CallMethod(shared_ptr<Component> sender, const WString& name, const std::vector<std::any>& arguments);
};