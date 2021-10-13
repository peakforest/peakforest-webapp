package fr.metabohub.peakforest.security.dao;

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
public class MetaDbSessionFactoryManager {

	private static SessionFactory metaDbSessionFactory;
	private static MetaDbSessionFactoryManager instance;

	private MetaDbSessionFactoryManager() {
	}

	/**
	 * returns the unique instance of SessionFactoryManagementService
	 * 
	 * @return SessionFactoryManager
	 */
	public static MetaDbSessionFactoryManager getInstance() throws Exception {
		if (instance == null)
			instance = new MetaDbSessionFactoryManager();
		return instance;
	}

	public SessionFactory getMetaDbSessionFactory() {
		if (metaDbSessionFactory == null || (metaDbSessionFactory != null && metaDbSessionFactory.isClosed())) {

			metaDbSessionFactory = createMetaDbSessionFactory();
		} else {
			try {
				Session session = metaDbSessionFactory.openSession();
				session.beginTransaction().commit();
				session.close();
			} catch (Exception e) {
				// if the metaDbSessionFactory exists, check if it has not expired yet
				// (SessionFactory.isClosed() doesn't work)
				metaDbSessionFactory.close();
				metaDbSessionFactory = null;
				metaDbSessionFactory = createMetaDbSessionFactory();
			}
		}

		return metaDbSessionFactory;
	}

	private SessionFactory createMetaDbSessionFactory() {
		Configuration configuration = new Configuration();
		configuration.configure(Utils.getBundleConfElement("hibernate.metadb.configuration.file"));
		String host = Utils.getBundleConfElement("hibernate.connection.meta.database.host");
		// String port = Utils.getBundleConfElement("hibernate.connection.meta.database.port");
		String dbType = Utils.getBundleConfElement("hibernate.connection.meta.database.type");
		String dbName = Utils.getBundleConfElement("hibernate.connection.meta.database.dbName");
		String login = Utils.getBundleConfElement("hibernate.connection.meta.database.username");
		String password = Utils.getBundleConfElement("hibernate.connection.meta.database.password");

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