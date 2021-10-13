package fr.metabohub.peakforest.utils;

import javax.servlet.ServletContext;
import javax.servlet.ServletContextEvent;

import fr.metabohub.peakforest.security.model.User;
import fr.metabohub.peakforest.security.services.UserManagementService;
import fr.metabohub.peakforest.services.LicenseManager;

/**
 * Class use to implement method called during WebApp startup / shutdown /
 * restart
 * 
 * @author Nils Paulhe
 *
 */
public class PeakForestListener implements javax.servlet.ServletContextListener {

	/**
	 * restart context
	 * 
	 * @param context the current context
	 */
	public void contextInitialized(final ServletContext context) {
		// reset log
		SpectralDatabaseLogger.resetLog();
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see javax.servlet.ServletContextListener#contextInitialized(javax.servlet.
	 * ServletContextEvent)
	 */
	@Override
	public void contextInitialized(final ServletContextEvent sce) {
		// init log
		SpectralDatabaseLogger.initLog();
		// check if admin in conf file is admin in db
		String adminMail = PeakForestUtils.getBundleConfElement("admin.email");
		checkIfIsAdmin(adminMail);
		// check if license admin is admin in db
		if (LicenseManager.licenseFileExists()) {
			LicenseManager.getLicenseData();
			String adminAltMail = LicenseManager.getAdminEmail();
			if (!adminMail.equals(adminAltMail))
				checkIfIsAdmin(adminAltMail);
		} else {
			// create license file
			LicenseManager.updateLicenseData(adminMail, "", LicenseManager.LICENSE_AUTH_FREE);
			startupLog("license file created!");
		}
		// TODO_LTS check license authorizations
	}

	/**
	 * Check if a user (with its email) is admin. If it is in the Meta database
	 * without the correct rights this method will promote it to the corrects one.
	 * 
	 * @param adminMail the email to rest
	 */
	private void checkIfIsAdmin(final String adminMail) {
		User adminUser = null;
		try {
			adminUser = UserManagementService.read(adminMail);
		} catch (final Exception e) {
			e.printStackTrace();
		}
		// check if user exists with correct rights
		if (adminUser != null && !adminUser.isAdmin()) {
			// exist but not root -> upgrade!
			try {
				UserManagementService.activate(adminUser.getId());
				UserManagementService.changeRight(User.ADMIN, adminUser.getId());
			} catch (final Exception e) {
				e.printStackTrace();
			}
		} else if (adminUser == null) {
			// does not exist: log
			startupLog("admin user '" + adminMail + "' not created in database! two options to solve the problem: ");
			startupLog("	option 1 - set it in config file and restart server.");
			startupLog("	option 2 - create it via web-gui and restart server.");
		}
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see javax.servlet.ServletContextListener#contextDestroyed(javax.servlet.
	 * ServletContextEvent)
	 */
	@Override
	public void contextDestroyed(final ServletContextEvent sce) {
		SpectralDatabaseLogger.closeLog();
	}

	/**
	 * Log startup / shutdown message (log lvl: WARNING)
	 * 
	 * @param logMessage the message to log
	 */
	private void startupLog(final String logMessage) {
		SpectralDatabaseLogger.log(logMessage, SpectralDatabaseLogger.LOG_WARNING);
	}

}