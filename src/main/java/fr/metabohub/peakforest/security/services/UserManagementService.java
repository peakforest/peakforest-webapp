package fr.metabohub.peakforest.security.services;

import java.util.List;

import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.hibernate.Transaction;
import org.springframework.security.crypto.password.StandardPasswordEncoder;

import fr.metabohub.peakforest.security.dao.MetaDbSessionFactoryManager;
import fr.metabohub.peakforest.security.dao.UserDao;
import fr.metabohub.peakforest.security.model.User;

/**
 * @author Nils Paulhe
 * 
 */
public class UserManagementService {

	/**
	 * @param newUser
	 * @return
	 * @throws Exception
	 */
	public static long create(User newUser) throws Exception {
		SessionFactory metaDbSessionFactory = MetaDbSessionFactoryManager.getInstance()
				.getMetaDbSessionFactory();
		Long id = null;
		Session session = metaDbSessionFactory.openSession();
		Transaction transaction = null;
		try {
			transaction = session.beginTransaction();
			id = create(session, newUser);
			transaction.commit();
		} catch (Exception e) {
			transaction.rollback();
			e.printStackTrace();
		} finally {
			session.close();
		}
		return id;
	}

	/**
	 * @param session
	 * @param user
	 * @return
	 */
	public static Long create(Session session, User user) {
		long id = UserDao.create(session, user);
		return id;
	}

	/**
	 * @param id
	 * @return
	 * @throws Exception
	 */
	public static User read(long id) throws Exception {
		SessionFactory metaDbSessionFactory = MetaDbSessionFactoryManager.getInstance()
				.getMetaDbSessionFactory();
		return UserDao.read(metaDbSessionFactory, id);
	}

	/**
	 * @param session
	 * @param id
	 * @return
	 * @throws Exception
	 */
	public static User read(Session session, long id) throws Exception {
		return UserDao.read(session, id);
	}

	/**
	 * @param userMail
	 * @return
	 * @throws Exception
	 */
	public static User read(String email) throws Exception {
		SessionFactory metaDbSessionFactory = MetaDbSessionFactoryManager.getInstance()
				.getMetaDbSessionFactory();
		return UserDao.read(metaDbSessionFactory, email);
	}

	public static boolean exists(String userMail) throws Exception {
		boolean exists = false;
		SessionFactory metaDbSessionFactory = MetaDbSessionFactoryManager.getInstance()
				.getMetaDbSessionFactory();
		Session session = metaDbSessionFactory.openSession();
		Transaction transaction = null;
		try {
			transaction = session.beginTransaction();
			exists = UserDao.exists(session, userMail);
			transaction.commit();
		} catch (Exception e) {
			transaction.rollback();
			e.printStackTrace();
		} finally {
			session.close();
		}
		return exists;
	}

	public static List<User> readAll() throws Exception {
		SessionFactory metaDbSessionFactory = MetaDbSessionFactoryManager.getInstance()
				.getMetaDbSessionFactory();
		return UserDao.readAll(metaDbSessionFactory);
	}

	/**
	 * 
	 * @param containedString
	 * @return
	 * @throws Exception
	 */
	public static List<User> search(String containedString) throws Exception {
		SessionFactory metaDbSessionFactory = MetaDbSessionFactoryManager.getInstance()
				.getMetaDbSessionFactory();
		Session session = metaDbSessionFactory.openSession();
		List<User> users = null;
		Transaction transaction = null;
		try {
			transaction = session.beginTransaction();
			users = UserDao.search(session, containedString);
			transaction.commit();
		} catch (Exception e) {
			transaction.rollback();
			e.printStackTrace();
		} finally {
			session.close();
		}
		return users;
	}

	/**
	 * @param userID
	 * @param newPassword
	 * @return
	 * @throws Exception
	 */
	public static boolean resetPassword(long userID, String newPassword) throws Exception {
		SessionFactory metaDbSessionFactory = MetaDbSessionFactoryManager.getInstance()
				.getMetaDbSessionFactory();
		Session session = metaDbSessionFactory.openSession();
		User user = null;
		Transaction transaction = null;
		try {
			transaction = session.beginTransaction();
			user = UserDao.read(session, userID);
			user.setPassword(newPassword);
			transaction.commit();
		} catch (Exception e) {
			transaction.rollback();
			e.printStackTrace();
		} finally {
			session.close();
		}
		return true;
	}

	/**
	 * @param userID
	 * @param login
	 * @param email
	 * @return
	 * @throws Exception
	 */
	public static boolean update(long userID, String login, String email) throws Exception {
		SessionFactory metaDbSessionFactory = MetaDbSessionFactoryManager.getInstance()
				.getMetaDbSessionFactory();
		Session session = metaDbSessionFactory.openSession();
		User user = null;
		Transaction transaction = null;
		try {
			transaction = session.beginTransaction();
			user = UserDao.read(session, userID);
			user.setLogin(login);
			user.setEmail(email);
			transaction.commit();
		} catch (Exception e) {
			transaction.rollback();
			e.printStackTrace();
		} finally {
			session.close();
		}
		return true;
	}

	/**
	 * @param userID
	 * @param login
	 * @param email
	 * @param right
	 * @return
	 * @throws Exception
	 */
	public static boolean updateAdmin(long userID, String login, String email, int right) throws Exception {
		SessionFactory metaDbSessionFactory = MetaDbSessionFactoryManager.getInstance()
				.getMetaDbSessionFactory();

		Session session = metaDbSessionFactory.openSession();
		User user = null;
		Transaction transaction = null;
		try {
			transaction = session.beginTransaction();

			user = UserDao.read(session, userID);

			user.setLogin(login);
			user.setEmail(email);

			switch (right) {
			case User.NORMAL:
				user.setAdmin(false);
				break;
			case User.ADMIN:
				user.setAdmin(true);
				break;
			default:
				user.setAdmin(false);
				break;
			}

			transaction.commit();
		} catch (Exception e) {
			transaction.rollback();
			e.printStackTrace();
		} finally {
			session.close();
		}
		return true;
	}

	/**
	 * @param right
	 * @param userID
	 * @return
	 * @throws Exception
	 */
	public static boolean changeRight(int right, long userID) throws Exception {
		SessionFactory metaDbSessionFactory = MetaDbSessionFactoryManager.getInstance()
				.getMetaDbSessionFactory();
		Session session = metaDbSessionFactory.openSession();
		User user = null;
		Transaction transaction = null;
		try {
			transaction = session.beginTransaction();

			user = UserDao.read(session, userID);

			switch (right) {
			case User.NORMAL:
				user.setCurator(false);
				user.setAdmin(false);
				break;
			case User.CURATOR:
				user.setCurator(true);
				user.setAdmin(false);
				break;
			case User.ADMIN:
				user.setCurator(true);
				user.setAdmin(true);
				break;
			default:
				user.setCurator(false);
				user.setAdmin(false);
				break;
			}
			transaction.commit();
		} catch (Exception e) {
			transaction.rollback();
			e.printStackTrace();
		} finally {
			session.close();
		}
		return true;

	}

	/**
	 * @param userID
	 * @return
	 * @throws Exception
	 */
	public static boolean delete(long userID) throws Exception {
		SessionFactory metaDbSessionFactory = MetaDbSessionFactoryManager.getInstance()
				.getMetaDbSessionFactory();
		Session session = metaDbSessionFactory.openSession();
		Transaction transaction = null;
		try {
			transaction = session.beginTransaction();
			UserDao.delete(session, userID);

			transaction.commit();
		} catch (Exception e) {
			transaction.rollback();
			e.printStackTrace();
		} finally {
			session.close();
		}
		return true;
	}

	/**
	 * @param email
	 * @return
	 * @throws Exception
	 */
	public static boolean delete(String email) throws Exception {
		SessionFactory metaDbSessionFactory = MetaDbSessionFactoryManager.getInstance()
				.getMetaDbSessionFactory();
		Session session = metaDbSessionFactory.openSession();
		Transaction transaction = null;
		try {
			transaction = session.beginTransaction();
			UserDao.delete(session, email);

			transaction.commit();
		} catch (Exception e) {
			transaction.rollback();
			e.printStackTrace();
		} finally {
			session.close();
		}
		return true;
	}

	/**
	 * Update a user basic data and his password
	 * 
	 * @param userID
	 * @param userEmail
	 * @param userFamilyName
	 * @param userFirstName
	 * @param userPassword
	 * @return
	 * @throws Exception
	 */
	public static boolean update(long userID, String login, String email, String userPassword,
			char userMainTechnology) throws Exception {
		SessionFactory metaDbSessionFactory = MetaDbSessionFactoryManager.getInstance()
				.getMetaDbSessionFactory();

		Session session = metaDbSessionFactory.openSession();
		User user = null;
		Transaction transaction = null;
		try {
			transaction = session.beginTransaction();

			user = UserDao.read(session, userID);

			user.setLogin(login);
			user.setEmail(email);

			if (userPassword != null) {
				StandardPasswordEncoder encoder = new StandardPasswordEncoder();
				user.setPassword(encoder.encode(userPassword));
			}

			user.setMainTechnology(userMainTechnology);

			transaction.commit();
		} catch (Exception e) {
			transaction.rollback();
			e.printStackTrace();
		} finally {
			session.close();
		}
		return true;
	}

	/**
	 * @param user
	 * @return
	 * @throws Exception
	 */
	public static boolean update(User user) throws Exception {
		SessionFactory metaDbSessionFactory = MetaDbSessionFactoryManager.getInstance()
				.getMetaDbSessionFactory();
		UserDao.update(metaDbSessionFactory, user);

		return true;
	}

	/**
	 * @param login
	 * @return
	 * @throws Exception
	 */
	public static User readLogin(String login) throws Exception {
		SessionFactory metaDbSessionFactory = MetaDbSessionFactoryManager.getInstance()
				.getMetaDbSessionFactory();
		return UserDao.readLogin(metaDbSessionFactory, login);
	}

	/**
	 * 
	 * @param containedString
	 * @return
	 * @throws Exception
	 */
	public static List<User> search(String containedString, int filter) throws Exception {
		SessionFactory metaDbSessionFactory = MetaDbSessionFactoryManager.getInstance()
				.getMetaDbSessionFactory();
		Session session = metaDbSessionFactory.openSession();
		List<User> users = null;
		Transaction transaction = null;
		try {
			transaction = session.beginTransaction();
			users = UserDao.search(session, containedString, filter);
			transaction.commit();
		} catch (Exception e) {
			transaction.rollback();
			e.printStackTrace();
		} finally {
			session.close();
		}
		return users;
	}

	public static void activate(long userId) throws Exception {
		SessionFactory metaDbSessionFactory = MetaDbSessionFactoryManager.getInstance()
				.getMetaDbSessionFactory();
		Session session = metaDbSessionFactory.openSession();
		Transaction transaction = null;
		try {
			transaction = session.beginTransaction();
			UserDao.activate(session, userId);
			transaction.commit();
		} catch (Exception e) {
			transaction.rollback();
			e.printStackTrace();
		} finally {
			session.close();
		}
	}

	public static void activateAll() throws Exception {
		SessionFactory metaDbSessionFactory = MetaDbSessionFactoryManager.getInstance()
				.getMetaDbSessionFactory();
		Session session = metaDbSessionFactory.openSession();
		Transaction transaction = null;
		try {
			transaction = session.beginTransaction();
			UserDao.activateAll(session);
			transaction.commit();
		} catch (Exception e) {
			transaction.rollback();
			e.printStackTrace();
		} finally {
			session.close();
		}
	}

	public static void desactivate(long userId) throws Exception {
		SessionFactory metaDbSessionFactory = MetaDbSessionFactoryManager.getInstance()
				.getMetaDbSessionFactory();
		Session session = metaDbSessionFactory.openSession();
		Transaction transaction = null;
		try {
			transaction = session.beginTransaction();
			UserDao.desactivate(session, userId);
			transaction.commit();
		} catch (Exception e) {
			transaction.rollback();
			e.printStackTrace();
		} finally {
			session.close();
		}
	}

	public static void activate(List<Long> ids) throws Exception {
		SessionFactory metaDbSessionFactory = MetaDbSessionFactoryManager.getInstance()
				.getMetaDbSessionFactory();
		Session session = metaDbSessionFactory.openSession();
		Transaction transaction = null;
		try {
			transaction = session.beginTransaction();
			UserDao.activate(session, ids);
			transaction.commit();
		} catch (Exception e) {
			transaction.rollback();
			e.printStackTrace();
		} finally {
			session.close();
		}
	}

	/**
	 * @return
	 * @throws Exception
	 */
	public static String renewToken(long id) throws Exception {
		SessionFactory metaDbSessionFactory = MetaDbSessionFactoryManager.getInstance()
				.getMetaDbSessionFactory();
		String newToken = null;
		Session session = metaDbSessionFactory.openSession();
		Transaction transaction = null;
		try {
			transaction = session.beginTransaction();
			newToken = UserDao.renewToken(session, id);
			transaction.commit();
		} catch (Exception e) {
			transaction.rollback();
			e.printStackTrace();
		} finally {
			session.close();
		}
		return newToken;
	}

}
