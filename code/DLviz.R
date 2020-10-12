
#### Libraries, wd ----
library(rnaturalearth)
library(readxl)
library(tidyverse)
library(sf)
library(sp)
library(ggthemes)


#### Import data ----
myCountries = ne_countries(continent = "North America",
                           returnclass = "sf")
myStates = USAboundaries::us_states()
myDLs = read_xlsx("data/LicenseName.xlsx")

#### Data wrangling ----
# Choose a projection
myCRS = CRS("+proj=aea +lat_1=20 +lat_2=60 +lat_0=40 +lon_0=-96 +x_0=0 +y_0=0 +ellps=GRS80 +datum=NAD83 +units=m +no_defs ")

# Generate join ID column
myDLs$name = myDLs$State
# Join data
myStatesDL = full_join(myStates,
                       myDLs,
                       by = "name")
# Check for failures
myStatesDL %>%
  filter(is.na(LicenseName))

# Transform dataset to appropriate CRS
myCountriesPlot = myCountries %>%
  st_transform(myCRS)

myStatesPlot = myStatesDL %>%
  st_transform(myCRS)
myStatesPlot$`License Name` = myStatesPlot$LicenseName

#### Plot ----
myPlot = ggplot() +
  geom_sf(data = myCountriesPlot,
          fill = "grey90",
          col = "grey40") +
  geom_sf(data = myStatesPlot,
          aes(fill = `License Name`),
          col = "grey40",
          size = 0.2) +
  scale_fill_colorblind() +
  theme_minimal() +
  theme(panel.background = element_rect(fill = "powderblue"),
        panel.grid = element_line(color = "grey20",
                                  size = 0.2)) +
  ggtitle("What is your motor vehicle operator license called?")

ggsave(filename = "plots/myPlot.jpg",
       myPlot,
       width = 8, height = 6, units = "in", dpi = 600)
