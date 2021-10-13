package fr.metabohub.peakforest.dao.maps;

import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.hibernate.cfg.Configuration;
import org.hibernate.service.ServiceRegistry;
import org.hibernate.service.ServiceRegistryBuilder;

import fr.metabohub.peakforest.utils.Utils;

/**
 * @author Nils Paulhe
 * 
 */
public class ExtraDbSessionFactoryManager {

	private static SessionFactory extraDbSessionFactory;
	private static ExtraDbSessionFactoryManager instance;

	private ExtraDbSessionFactoryManager() {
	}

	/**
	 * returns the unique instance of SessionFactoryManagementService
	 * 
	 * @return SessionFactoryManager
	 */
	public static ExtraDbSessionFactoryManager getInstance() throws Exception {
		if (instance == null)
			instance = new ExtraDbSessionFactoryManager();
		return instance;
	}

	public SessionFactory getExtraDbSessionFactory() {
		if (extraDbSessionFactory == null
				|| (extraDbSessionFactory != null && extraDbSessionFactory.isClosed())) {

			extraDbSessionFactory = createExtraDbSessionFactory();
		} else {
			try {
				Session session = extraDbSessionFactory.openSession();
				session.beginTransaction().commit();
				session.close();
			} catch (Exception e) {
				// if the extraDbSessionFactory exists, check if it has not expired yet
				// (SessionFactory.isClosed() doesn't work)
				extraDbSessionFactory.close();
				extraDbSessionFactory = null;
				extraDbSessionFactory = createExtraDbSessionFactory();
			}
		}

		return extraDbSessionFactory;
	}

	private SessionFactory createExtraDbSessionFactory() {
		Configuration configuration = new Configuration();
		configuration.configure(Utils.getBundleConfElement("hibernate.extradb.configuration.file"));
		String host = Utils.getBundleConfElement("hibernate.connection.extra.database.host");
		// String port = Utils.getBundleConfElement("hibernate.connection.extra.database.port");
		String dbType = Utils.getBundleConfElement("hibernate.connection.extra.database.type");
		String dbName = Utils.getBundleConfElement("hibernate.connection.extra.database.dbName");
		String login = Utils.getBundleConfElement("hibernate.connection.extra.database.username");
		String password = Utils.getBundleConfElement("hibernate.connection.extra.database.password");

		String jdbcURL = null;
		if (dbType.toLowerCase().startsWith("h2")) {
			jdbcURL = "jdbc:" + dbType + ":" + dbName;
			// if (dbType.toLowerCase().indexOf("mem") != -1) {
			//
			// } else {
			//
			// }
			jdbcURL += ";DB_CLOSE_ON_EXIT=FALSE";
		} else
			jdbcURL = "jdbc:" + dbType + "://" + host + "/" + dbName;
		configuration.setProperty("hibernate.connection.url", jdbcURL);
		configuration.setProperty("hibernate.connection.username", login);
		configuration.setProperty("hibernate.connection.password", password);

		ServiceRegistry serviceRegistry = new ServiceRegistryBuilder().applySettings(
				configuration.getProperties()).buildServiceRegistry();
		return configuration.buildSessionFactory(serviceRegistry);
	}
}