---
layout: post
title:  "SymbiYosys Cheatsheet"
post-title:  "SymbiYosys Cheatsheet"
date:   2021-11-03 16:52:46 -0500
permalink: /tutorials/symbiyosys_cheatsheet
permalink_name: /symbiyosys_cheatsheet
category: tutorials
description: "Cheatsheet for formal proofs using SymbiYosys"

categories: tutorial verilog
---

---

This cheatsheet shows you the basics of using SymbiYosys on your Verilog code to formally verify it's functionality.

You'll need to download the SymbiYosys toolchain and the solvers by following [this tutorial](https://symbiyosys.readthedocs.io/en/latest/install.html).

You're also going to want GTKWave 
```shell
sudo apt install gtkwave
```

---
# What is SymbiYosys
It's a formal proof tool that runs on your HDL design to ensure that it does what you expect.

---
# Why The Hell Do You Care?
Formal proofs guarantee your HDL code does what the spec states it will(if you do them properly). More importantly, it's easier than testbenches typically (but not a complete substitute!)

---
# Why SymbiYosys
The Verilog version's free. That's all folks, can't say I personally know of other tools like this, but they must exist.

---
# Overview
This cheatsheet goes over

* Solvers
* BMC
* Prove
* Example .sby File
* Basics Assertions
* Code Examples
* Looking at Failure Traces


---
# Solvers
Remember that one class you had to take where you learned about formal proofs, k-induction proofs, and all the magic that you can do with modulo?

Well imagine if all that was done for you and you could just take the results :)

[SMT](https://en.wikipedia.org/wiki/Satisfiability_modulo_theories) solvers will take an array of assertions for you and ensure their true. SymbiYosys will format your RTL code so it can be piped through these solvers. Technically I think some solvers use SAT solvers but ya, if you care look into it more on your own.

The default solver(Yices 2) is usually fine for all intents and purposes. If I decide to do this for grad school then I'll probably have a much stronger opinion.

---
# BMC
Bounded Model Check is a method of running a set of specification through N trials to ensure no counter example is found. It doesn't prove anything, but it sure as hell can find bugs quickly.

If you want to read on why it exists and the advantage of it over the old school method of doing purely boolean comparisons read [this](http://www.cs.cmu.edu/~emc/papers/Books%20and%20Edited%20Volumes/Bounded%20Model%20Checking.pdf)

---
# Prove
Those k-induction proofs I mentioned? The ones that seem like voodoo that you learned to pass that one test way back when?

They're actually useful, and more importantly, they're solved for you now. These prove that the assertions you make hold true for all time by proving that f(1) is true, then assuming and proving it's true for f(k+1)

Here's a nice [video](https://www.youtube.com/watch?v=IFqna5F0kW8) to show you the basics of induction.

---
# Example demo.sby File
```shell
[tasks]
bmc
prv

[options]
bmc: mode bmc
bmc: depth 100
prv: mode prove

[engines]
smtbmc

[script]
read -formal demo.v
prep -top demo

[files]
demo.v

```

Tasks: These are different run configurations you can select from. You can run one at a time or all of them.
```shell
sby -f demo.sby bmc   # Run only BMC
sby -f demo.sby       # Run all tasks in order
```

You can see the different run options in the options section. You can see the area to specify your solving engine.

The next important part is to specify your source (demo.v in this case). Prep your top level module, and make sure to point to the file.

---
# Basics
There are 3 types of statements you can use. These statements must lie within the formal ifdefs, and they must fall in one of the below blocks
```verilog
`ifdef FORMAL
always @(posedge clk)
    assert(statement);
    
always @(*)
    assert(statement);
`endif
```
The statements are shown here
* assume(expression)
  * Things that the solver will always hold true. Limits the area the solver works in. One example is a known starting state would be assumed
* assert(expression)
  * The solver will do everything possible to prove that this statement is false. If it does it will return a fail for BMC or an UNKNOWN for induction
* cover(expression)
  * These only apply when you run in cover mode. They will try to do everything they can to prove the expression true within N runs. If they reach them all it will pass. If they don't, or if they reach them by breaking an assert statement it will fail.

---
# Code Examples
```verilog
//demo.v
module demo (
    input i_clk,
    input i_en,
    output reg [4:0] o_counter
);

reg enable;
initial o_counter = 0;
initial enable = 0;

always @(posedge i_clk) begin
    enable <= i_en;
    if(enable)begin
        if(o_counter == 15)
            o_counter <= 0;
        else
            o_counter <= o_counter + 1'b1;
    end
end


`ifdef FORMAL
always @(posedge i_clk) begin
    assert(o_counter < 16);
    if($past(o_counter) == 15)  //Spot the bug? Look at the generated trace to see it
    //if($past(o_counter) == 15 & $past(enable))  //Fixed version
        assert(o_counter == 0);
end
`endif
endmodule
```
Here's a extremely simple counter module where we make some statements about the formal properties. Spot the bug in the
proof? Run the proof by doing this with the demo.v and demo.sby files in the same directory
```shell
sby -f demo.sby bmc
```
You should see it fail. Look at the trace it generates in GTK Wave to spot it. Got it?

(We forget to assert that $past(enable) must be high for o_counter to change in the second assertion)

This is obviously a pretty dumb example, but trust me this stuff helps a lot compared to a standard test bench.

---
# Viewing the Output Trace
```shell
gtkwave demo_bmc/engine_0/trace.vcd
```
<img src="/assets/images/posts/tutorials/symbiyosys_cheatsheet/failed_trace.png" alt="BMC Trace" width="700">
Look at the final tick of the clock. You can see enable was pulled low and therefore your output didn't change? That's a bug in our proof, not the code. Fix it with the commented out line.

Now run
```shell
sby -f demo.sby bmc   #Does it pass?
sby -f demo.sby prv   #Does it pass?
```

---
# Wrapping Up
Give formal verification a shot. If you hate it, you hate it. I like it for finding bugs, and it's pretty cool.

If you want to learn all about it check out [ZipCPU](https://zipcpu.com/). This guy has some awesome technical stuff on his site (but it is fairly complicated at times)

