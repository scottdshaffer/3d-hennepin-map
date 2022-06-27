#3d population density map

#load packages
library(tidyverse)
library(sf)
library(units)
library(rayshader)
library(tidycensus)
showtext_opts(dpi = 96)

#get Hennepin County population data
henn_pop_dens <- get_acs(geography = "tract",
                         state = "MN",
                         county = "Hennepin",
                         variable = "B01003_001",
                         year = 2020,
                         geometry = TRUE) %>% 
  mutate(area = st_area(geometry))

#calculate population density per square mile
henn_pop_dens$area <- set_units(henn_pop_dens$area, mi^2)
henn_pop_dens$dens <- henn_pop_dens$estimate/henn_pop_dens$area

#get a nice font
font_add_google("Crimson Pro", "crimson")

#set up the plot
pop_dens_map <- ggplot(henn_pop_dens) + geom_sf(aes(fill = as.numeric(dens)),
                                                color = NA) +
  labs(title = "Hennepin County, Minnesota",
       caption = "Scott Shaffer | April 2022 | tidycensus and rayshader packages") +
  scale_fill_viridis_c(name = "Population per\nsquare mile",
                       labels = scales::label_comma(scale = 1/1000, suffix = "k"),
                       direction = -1,
                       option = "mako") +
  coord_sf(datum = NA) +
  theme_minimal() + theme(text = element_text(family = "crimson"),
                          plot.title = element_text(hjust = .5),
                          plot.caption = element_text(face = "italic",
                                                      hjust = .5),
                          plot.background = element_rect(color = NA, fill = "white"),
                          legend.position = "bottom")
showtext_opts(dpi = 300)

#render plot
plot_gg(pop_dens_map,multicore = TRUE,width=5,height=5,scale=200,windowsize=c(1600,1200),
        zoom = 0.6, theta = 30, phi = 40)
render_camera(zoom = 0.45, theta = 30, phi = 35)
render_snapshot()

