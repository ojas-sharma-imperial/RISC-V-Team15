# RISC-V-Team15

This is the RISC-V processor design repository for Group 15. Our personal statements are available here:

| Name | CID | Personal Statement |
| :---: | :---: | :---: |
| Ojas Sharma | 02659577 | [click here](docs/personal_statements/ojas.md) |
| Ruben --- | --- | [click here](docs/personal_statements/ruben.md) |
| Darren --- | --- | [click here](docs/personal_statements/darren.md) |
| David --- | --- | [click here](docs/personal_statements/david.md) |

Our AI use declaration is provided [here](docs/AI_USE_DECLARATION.md).

## The Final Desgin

## Initial Design

We began by designing an unpipelined CPU, implementing the RV32I instruction set, creating each module in a separate file, instantiating them in a `top.sv` file. We generally followed the [block diagram](docs/img/project_brief_block_diagram.png) provided in lectures to structure our work, dividing the group roughly into controlpath and datapath design. We made slight modifications to the diagram to make implementation easier for us, all of which are documented in the [control specification](docs/CONTROLSPEC.md).

We wrote effective tests and verified the processor could run the counter software using both exhaustive testing methods and waveforms in gtkWave.

## Pipelining

We then implemented a 5-stage pipeline to the processor loosely following the [new block diagram](docs/img/pipelined_block_diagram.png) provided in lectures, again modifying it to suit our different control signals. We created dedicated module files with the relevant inputs and outputs for our four pipeline registers. We also added a hazard unit, and implemented forwarding and stalls using multiplexers with select lines connected to hazard unit outputs.