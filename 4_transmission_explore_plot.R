# Load packages, data files and functions
source("99_dependencies.R")
source("99_model_func.R")
source("99_parm_init_control.R")


r.int <- seq(0, 1, 0.1)
param <- param.dcm(latent = latent,
                   infectious = infectious,
                   isolation = isolation,
                   beta_student_to_student = r.int*R0_student_to_student/infectious,
                   beta_on_to_on = r.int*R0_on_to_on/infectious,
                   beta_saf = r.int*R0_saf/infectious,
                   contacts = contacts,
                   sensitivity = sensitivity,
                   testing = 0,
                   screening = screening)
mod <- dcm(param, init, control)
mod <- mutate_epi(mod, I_stu = I_on + I_off,
                  Icum_stu = Icum_on + Icum_off,
                  P_stu = P_on + P_off,
                  Q_stu = Q_on + Q_off,
                  Pcum_stu = Pcum_on + Pcum_off,
                  Qcum_stu = Qcum_on + Qcum_off)

pal <- brewer_ramp(mod$control$nruns, "Spectral")


# Transmission reduction  Scenarios
tiff("Plots/4_transmission_explore.tiff", units="in", width=6, height=5, res=300)
m <- rbind(c(1,2))
layout(m)
par(mar = c(3,3,2,1), mgp = c(2,1,0))
plot(mod, y = "I_stu", main = "Active Cases (Students)", col = pal, legend = FALSE,
     ylab = "Cases")
plot(mod, y = "I_saf", main = "Active Cases (Staff/faculty)", col = pal,
     ylim = c(0, max(mod$epi$I_stu)),legend = FALSE)
legend("topleft", legend = c("No reduction" , "50% reduction", "No transmission"), lwd = 3,
       col = c(pal[length(pal)], pal[6], pal[1]), bty = "n", cex = 0.6,)
dev.off()


# plot(mod, y = "I_saf", main = "C) Active Cases (Staff/Faculty)", col = pal, legend = FALSE)
# plot(mod, y = "Icum_saf", main = "D) Cumulative Cases (Staff/Faculty)", col = pal, legend = FALSE)
# plot(dfLast$scrInt, dfLast$Icum_stu, type = "l", lwd = 5, col = pal[1],
#      ylim = c(0, max(dfLast$Icum_stu)),
#      ylab = "Cumulative Cases", xlab = "Screening Interval (Days)",
#      main = "E) Cumulative Cases")
# lines(dfLast$scrInt, dfLast$Icum_saf, lwd = 5, col = pal[length(pal)])
# legend("topleft", legend = c("Students", "Staff/Faculty"), lwd = 3,
#        col = c(pal[1], pal[length(pal)]), bty = "n", cex = 0.8)