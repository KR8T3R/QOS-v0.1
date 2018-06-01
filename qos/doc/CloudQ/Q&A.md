# [**Quantum Computing Cloud Accessed](http://quantumcomputer.ac.cn) Q&A**

## About the system status
The system status can be found at: _Parameters_ > _Status_
The system have four states: **ACTIVE**, **CALIBRATION**, **MAINTENANCE**, **OFFLINE**
**ACTIVE**: the system is running tasks or ready to run tasks, in this state, user submitted quantum circuits will be executed
immediately if it is the first in the task queue, a circuit execution takes only a few seconds.
**CALIBRATION**: the system is performing calibrations. There are four levels of calibrations and takes 1 to 50 minutes to finished. About half of the time the system in performing calibrations, that means a blindly submitted task has a 50% of chance to be executed immediately.
**MAINTENANCE**: The backend is connected but not offering online services, we are doing some maintenance work, running local experiments
for example. During this state the parameter updation will be continued. 
**OFFLINE**: the backend is not connected.
_Note: Experiment tasks can be submitted at any time, they will be executed at a later time if not executed immediately._  

## How a submitted experiment is run
The QOS qcp backend downloads the first experiment task in the task queue, compiles the circuit and runs it on the quantum processor, if successful, the result is uploaded, if not, an error message will be uploaded. The whole process runs automatically without human intervention or surveillance, if the result appears wrong, it may due to the fact that the system is in a _mal-calibrated-state_, the user may try submit the experiment in a later time.

## About the sample
The backend is a 12-bit Xmon qubit superconducting quantum chip with direct neighbouring coupling. Each qubit can be controled by its _XY_, _z_ and _frequency tuning_ control line, the qubit states are readout by readout resonators that are dispersively coupled to each qubit. One qubit is not used due to not enough control cables on the installed fridge.

## Got questions/bug reports/comments/etc.
**Quantum Computing Cloud Accessed** related please contact by the support email support@quantum-computer.com.cn
[**QOS(control software)**](https://github.com/YulinWu/QOS-v0.1) related please contact the owner of this repo.

## Explanation of the results 
TODO...