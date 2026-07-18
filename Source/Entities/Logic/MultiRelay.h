#pragma once
#include "Leadwerks.h"
#include "../BaseComponent.h"

using namespace Leadwerks;

class MultiRelay : public BaseComponent//Component
{
private:
    
    struct TimedSignal {
        double time; // scheduled time in milliseconds
        String output;
    };
    std::list<TimedSignal> queue;

public: 

    int delay1 = 0;//"Delay 1"
    int delay2 = 0;//"Delay 2"
    int delay3 = 0;//"Delay 3"
    int delay4 = 0;//"Delay 4"
    int delay5 = 0;//"Delay 5"
    int delay6 = 0;//"Delay 6"
    int delay7 = 0;//"Delay 7"
    int delay8 = 0;//"Delay 8"

    virtual void Signal();//in
    virtual void Output1();//out
    virtual void Output2();//out
    virtual void Output3();//out
    virtual void Output4();//out
    virtual void Output5();//out
    virtual void Output6();//out
    virtual void Output7();//out
    virtual void Output8();//out
    
    virtual void Update();
	virtual bool Load(table& properties, std::shared_ptr<Stream> binstream, std::shared_ptr<Scene> scene, const LoadFlags flags, std::shared_ptr<Object> extra);
    virtual std::shared_ptr<Component> Copy();
    virtual std::any CallMethod(shared_ptr<Component> sender, const WString& name, const std::vector<std::any>& arguments);
};