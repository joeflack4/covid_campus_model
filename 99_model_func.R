model <- function(t, t0, parms) {
  with(as.list(c(t0, parms)), {

    # ODEs
    # On campus students
    lam_on = (1-eff_npi)*(beta_student_to_student*(I_off+I_on)+ beta_on_to_on*I_on + beta_saf*I_saf)
    
    dS_on <- -lam_on*S_on - community*S_on - testing*(1-p_asympt_stu)*I_on*sensitivity*(contacts-R0_on_to_on-R0_student_to_student)*p_contacts_reached + 1/isolation*Q_on*((contacts-R0_on_to_on-R0_student_to_student)/contacts)
    dE_on <-  lam_on*S_on + community*S_on - 1/latent*E_on  - screening*E_on*sensitivity - testing*(1-p_asympt_stu)*I_on*sensitivity*(R0_on_to_on+R0_student_to_student)*p_contacts_reached #last term represents contract tracing
    dI_on <- 1/latent*E_on - testing*(1-p_asympt_stu)*sensitivity*I_on - 1/infectious*I_on - screening*I_on*sensitivity
    dIsym_on <- (1-p_asympt_stu)*(1/latent*E_on - testing*(1-p_asympt_stu)*sensitivity*I_on - 1/infectious*I_on - screening*I_on*sensitivity)
    dR_on <- 1/infectious*I_on + 1/isolation*P_on + 1/isolation*Q_on*((R0_on_to_on+R0_student_to_student)/contacts)
    
    dP_on <- testing*(1-p_asympt_stu)*sensitivity*I_on + screening*(E_on+I_on)*sensitivity - 1/isolation*P_on
    dQ_on <- testing*(1-p_asympt_stu)*I_on*sensitivity*contacts*p_contacts_reached  - 1/isolation*Q_on

    dIcum_on <- (1-p_asympt_stu)*1/latent*E_on
    dPcum_on <- testing*(1-p_asympt_stu)*I_on*sensitivity + screening*(E_on+I_on)*sensitivity
    dQcum_on <- testing*(1-p_asympt_stu)*I_on*sensitivity*contacts*p_contacts_reached
    dHcum_on <- lam_on*S_on*p_hosp_stu
    dDcum_on <- lam_on*S_on*p_death_stu

    # Off campus students
    lam_off = (1-eff_npi)*(beta_student_to_student*(I_off+I_on) + beta_saf*I_saf)
    
    dS_off <- -lam_off*S_off - community*S_off - testing*(1-p_asympt_stu)*I_off*sensitivity*(contacts - R0_student_to_student)*p_contacts_reached + 1/isolation*Q_off*((contacts-R0_student_to_student)/contacts)
    dE_off <-  lam_off*S_off + community*S_off - (1/latent)*E_off - screening*E_off*sensitivity - testing*(1-p_asympt_stu)*I_off*sensitivity*(R0_student_to_student)*p_contacts_reached
    dI_off <- 1/latent*E_off - testing*(1-p_asympt_stu)*I_off*sensitivity - 1/infectious*I_off - screening*I_off*sensitivity
    dIsym_off <- (1-p_asympt_stu)*(1/latent*E_off - testing*(1-p_asympt_stu)*I_off*sensitivity - 1/infectious*I_off - screening*I_off*sensitivity)
    dR_off <- 1/infectious*I_off + 1/isolation*P_off + 1/isolation*Q_off*(R0_student_to_student/contacts)

    dP_off <- testing*(1-p_asympt_stu)*I_off*sensitivity - 1/isolation*P_off + screening*(E_off+I_off)*sensitivity
    dQ_off <- testing*(1-p_asympt_stu)*I_off*sensitivity*contacts*p_contacts_reached - 1/isolation*Q_off

    dIcum_off = (1-p_asympt_stu)*1/latent*E_off 
    dPcum_off <- testing*(1-p_asympt_stu)*I_off*sensitivity + screening*(E_off+I_off)*sensitivity
    dQcum_off <-testing*(1-p_asympt_stu)*I_off*sensitivity*contacts*p_contacts_reached
    dHcum_off <- lam_off*S_off*p_hosp_stu
    dDcum_off <- lam_off*S_off*p_death_stu
    
    # Staff and faculty
    lam_saf = (1-eff_npi)*(beta_saf*(I_on+I_off+I_saf))
    
    dS_saf <- -lam_saf*S_saf - community*S_saf - testing*(1-p_asympt_saf)*I_saf*sensitivity*(contacts-R0_saf)*p_contacts_reached + 1/isolation*Q_saf*((contacts-R0_saf)/contacts)
    dE_saf <-  lam_saf*S_saf + community*S_saf - 1/latent*E_saf - screening*E_saf*sensitivity - testing*(1-p_asympt_saf)*I_saf*sensitivity*(R0_saf)*p_contacts_reached
    dI_saf <- 1/latent*E_saf - testing*(1-p_asympt_saf)*I_saf*sensitivity- 1/infectious*I_saf - screening*I_saf*sensitivity
    dIsym_saf <- (1-p_asympt_saf)*(1/latent*E_saf - testing*(1-p_asympt_saf)*I_saf*sensitivity- 1/infectious*I_saf - screening*I_saf*sensitivity)
    dR_saf <- 1/infectious*I_saf + 1/isolation*P_saf + 1/isolation*Q_saf*(R0_saf/contacts)
    
    dP_saf <- testing*(1-p_asympt_saf)*I_saf*sensitivity - 1/isolation*P_saf + screening*(E_saf+I_saf)*sensitivity
    dQ_saf <- testing*(1-p_asympt_saf)*I_saf*sensitivity*contacts*p_contacts_reached - 1/isolation*Q_saf

    dIcum_saf = (1-p_asympt_saf)*1/latent*E_saf 
    dPcum_saf <- testing*(1-p_asympt_saf)*lam_saf*S_saf*sensitivity
    dHcum_saf <- lam_saf*S_saf*p_hosp_saf
    dDcum_saf <- lam_saf*S_saf*p_death_saf

    #Calculated outputs
    dTest <- N*screening + ((I_on+I_off+I_saf)*testing) + N*ili*ifelse(testing > 0, 1, 0) #diagnostics performed
    dCase_stu =   (1-p_asympt_saf)*(1/latent*E_on - testing*(1-p_asympt_stu)*sensitivity*I_on - 1/infectious*I_on - screening*I_on*sensitivity +
                  1/latent*E_off - testing*(1-p_asympt_stu)*I_off*sensitivity - 1/infectious*I_off - screening*I_off*sensitivity)
                  

    state_list <- c(dS_on,dE_on,dI_on,dIsym_on, dP_on,dR_on,dIcum_on, dPcum_on, dQ_on, dQcum_on, dHcum_on, dDcum_on,
                    dS_off,dE_off,dI_off,dIsym_off,dP_off,dR_off,dIcum_off, dPcum_off, dQ_off, dQcum_off, dHcum_off, dDcum_off,
                    dS_saf,dE_saf,dI_saf,dIsym_saf, dP_saf,dR_saf,dIcum_saf,dPcum_saf, dQ_saf, dHcum_saf, dDcum_saf, 
                    dTest)
    out <- list(state_list)
    return(out)
  })
}
