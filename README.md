# AGRI-COOL System Model
## Introduction

This repository contains the **Modelica system model and simulation environment** developed in **Work Package 4 (System Integration & Digital Twin Development)** of the [AGRI-COOL project](https://agri-cool.eu/). AGRI-COOL is an EU-funded initiative that tackles post-harvest losses by deploying **solar-powered, off-grid cold storage** for fruits and vegetables.

WP4 builds **physics-based dynamic models** and a **digital twin** of AGRI-COOL systems. The goal is to analyze performance, improve energy efficiency, and adapt designs to local contexts.

## AGRI-COOL System at a Glance
Typical subsystems:
- **PV array** for renewable power  
- **Battery** for short-term electrical storage  
- **Chiller** to generate cooling  
- **Cold room** for produce  
- **Thermal Energy Storage (TES)**  to extend cooling capacity overnight  
- **control strategies** to balance demand and available solar energy  

The repository models these components and their interactions under variable weather and load.

## Repository Contents
- **`AGRI_COOL` Modelica package** with components and full system models  
- Example **system-level models** with two night control strategies  
- Resources for running simulations  

## Installation and Usage
### Requirements
- A Modelica tool: **[Dymola](https://www.3ds.com/products/catia/dymola/)** or **[OpenModelica](https://openmodelica.org/)**  
- **Modelica Standard Library 4.x**  
- This repo includes dependencies needed for stand-alone use where possible  

### Load the Package
1. Clone the repository:
   ```bash
   git clone https://github.com/B-BZ/AGRI_COOL-D4.1.git

2. **OpenModelica (OMEdit)**  
   - Open **OMEdit**  
   - Go to *File → Open Directory…*  
   - Select the repository root folder or `AGRI_COOL/package.mo`  
   - The `AGRI_COOL` package will appear in the Libraries Browser  

   **Documentation:**  
   - [OMEdit User Guide](https://openmodelica.org/doc/OpenModelicaUsersGuide/latest/omedit.html)  
   - [Package Manager Guide](https://openmodelica.org/doc/OpenModelicaUsersGuide/latest/packagemanager.html)

3. **Dymola**  
   - Open **Dymola**  
   - Go to *File → Open…*  
   - Select `AGRI_COOL/package.mo`  
   - The `AGRI_COOL` package will be loaded into the library tree  

   **Documentation:**  
   - [Getting Started with Dymola – Claytex PDF](https://www.claytex.com/wp-content/uploads/2010/03/Getting-started-with-Dymola.pdf)


### Run a Full AGRI-COOL System Simulation

To run the complete AGRI-COOL system, simulate one of the following top-level models:

- `AGRI_COOL.System.System_OL_NightCTRL`  
  *Implements open-loop night control logic*  

- `AGRI_COOL.System.System_CL_NightCTRL`  
  *Implements closed-loop night control logic*  

These represent two strategies for operating the system during periods without sunlight.

---

## Project Website
Learn more about AGRI-COOL: [https://agri-cool.eu/](https://agri-cool.eu/)

## Contact

For questions, issues, or collaboration, please reach out:

- **Name:** Bahareh Bakhsh Zahmatkesh  
- **Position:** PhD Candidate – University of Twente  
- **Email:** [bahareh.bakhshzahmatkesh@utwente.nl](mailto:bahareh.bakhshzahmatkesh@utwente.nl)
