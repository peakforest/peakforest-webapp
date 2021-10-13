/**
 * 
 */
package fr.metabohub.peakforest.security.dao;

import java.math.BigInteger;
import java.security.SecureRandom;
import java.util.Date;
import java.util.List;

import org.hibernate.HibernateException;
import org.hibernate.Query;
import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.hibernate.Transaction;

import fr.metabohub.peakforest.security.model.User;

/**
 * @author Nils Paulhe
 * 
 */
@SuppressWarnings("unchecked")
public class UserDao {

	/**
	 * @param sessionFactory
	 * @param user
	 * @return id, the new generated id
	 * @throws HibernateException
	 */
	public static Long create(SessionFactory sessionFactory, User user) throws HibernateException {
		Session session = sessionFactory.openSession();
		Transaction transaction = null;
		Long id = null;
		try {
			transaction = session.beginTransaction();
			id = create(session, user);
			transaction.commit();
		} catch (HibernateException e) {
			transaction.rollback();
			e.printStackTrace();
			throw e;
		} finally {
			session.close();
		}
		return id;
	}

	/**
	 * @param session
	 * @param descriptor
	 * @return id, the new generated id
	 * @throws HibernateException
	 */
	public static Long create(Session session, User user) throws HibernateException {
		Long id;
		user.setCreated(new Date());
		user.setUpdated(new Date());
		id = (Long) session.save(user);
		return id;
	}

	/**
	 * @param sessionFactory
	 * @param descriptor
	 * @throws HibernateException
	 */
	public static void update(SessionFactory sessionFactory, User user) throws HibernateException {
		Session session = sessionFactory.openSession();
		Transaction transaction = null;
		try {
			transaction = session.beginTransaction();
			update(session, user);
			transaction.commit();
		} catch (HibernateException e) {
			transaction.rollback();
			e.printStackTrace();
			throw e;
		} finally {
			session.close();
		}
	}

	/**
	 * @param session
	 * @param descriptor
	 * @throws HibernateException
	 */
	public static void update(Session session, User user) throws HibernateException {
		user.setUpdated(new Date());
		session.update(user);
	}

	/**
	 * @param sessionFactory
	 * @param id
	 * @return
	 * @throws HibernateException
	 */
	public static User read(SessionFactory sessionFactory, Long id) throws HibernateException {
		Session session = sessionFactory.openSession();
		Transaction transaction = null;
		User user = null;
		try {
			transaction = session.beginTransaction();
			user = read(session, id);
			transaction.commit();
		} catch (HibernateException e) {
			transaction.rollback();
			e.printStackTrace();
			throw e;
		} finally {
			session.close();
		}
		return user;
	}

	public static User read(Session session, Long id) {
		User user;
		user = (User) session.get(User.class, id);
		return user;
	}

	public static User load(Session session, Long id) {
		return (User) session.load(User.class, id);
	}

	/**
	 * @param sessionFactory
	 * @param email
	 * @return the user
	 * @throws HibernateException
	 */
	public static User read(SessionFactory sessionFactory, String email) throws HibernateException {
		Session session = sessionFactory.openSession();
		Transaction transaction = null;
		User user = null;
		try {
			transaction = session.beginTransaction();
			user = read(session, email);
			transaction.commit();
		} catch (HibernateException e) {
			transaction.rollback();
			e.printStackTrace();
			throw e;
		} finally {
			session.close();
		}
		return user;
	}

	/**
	 * @param session
	 * @param descriptorName
	 * @return the descriptor
	 * @throws HibernateException
	 */
	public static User read(Session session, String email) throws HibernateException {
		String queryString = "from " + User.class.getSimpleName() + " where email =:email";
		return (User) session.createQuery(queryString).setParameter("email", email).uniqueResult();
	}

	/**
	 * @param session
	 * @param email
	 * @return
	 * @throws HibernateException
	 */
	public static boolean exists(Session session, String email) throws HibernateException {
		boolean exists = false;
		String hqlQuery = "select count(*) from " + User.class.getSimpleName() + " where email =:email";
		Query query = session.createQuery(hqlQuery);
		query.setString("email", email);
		Object queryResult = query.uniqueResult();
		exists = queryResult != null && ((Long) queryResult).intValue() == 1;
		return exists;

	}

	/**
	 * @param session
	 * @param email
	 * @return
	 * @throws HibernateException
	 */
	public static boolean exists(SessionFactory sessionFactory, String email) throws HibernateException {
		Session session = sessionFactory.openSession();
		Transaction transaction = null;
		boolean exists = false;
		try {
			transaction = session.beginTransaction();
			exists = UserDao.exists(session, email);
			transaction.commit();
		} catch (Exception e) {
			transaction.rollback();
			e.printStackTrace();
		} finally {
			session.close();
		}
		return exists;
	}

	public static List<User> readAll(SessionFactory sessionFactory) {
		Session session = sessionFactory.openSession();
		Transaction transaction = null;
		List<User> users = null;
		try {
			transaction = session.beginTransaction();
			users = UserDao.readAll(session);
			transaction.commit();
		} catch (Exception e) {
			transaction.rollback();
			e.printStackTrace();
		} finally {
			session.close();
		}
		return users;
	}

	public static List<User> readAll(Session session) {
		return session.createQuery("from " + User.class.getSimpleName()).list();
	}

	public static List<User> search(Session session, String containedString) {
		String queryString = "from " + User.class.getSimpleName() + " where mail like :containedString";
		return session.createQuery(queryString).setParameter("containedString", "%" + containedString + "%")
				.list();
	}

	public static void delete(Session session, Long id) throws HibernateException {
		User user = read(session, id);
		session.delete(user);
	}

	/**
	 * @param session
	 * @param email
	 * @throws HibernateException
	 */
	public static void delete(Session session, String email) throws HibernateException {
		User user = read(session, email);
		session.delete(user);
	}

	/**
	 * @param sessionFactory
	 * @param email
	 * @throws HibernateException
	 */
	public static void delete(SessionFactory sessionFactory, String email) throws HibernateException {
		Session session = sessionFactory.openSession();
		Transaction transaction = null;
		try {
			transaction = session.beginTransaction();
			delete(session, email);
			transaction.commit();
		} catch (HibernateException e) {
			transaction.rollback();
			e.printStackTrace();
			throw e;
		} finally {
			session.close();
		}
	}

	/**
	 * @param sessionFactory
	 * @param id
	 * @throws HibernateException
	 */
	public static void delete(SessionFactory sessionFactory, long id) throws HibernateException {
		Session session = sessionFactory.openSession();
		Transaction transaction = null;
		try {
			transaction = session.beginTransaction();
			delete(session, id);
			transaction.commit();
		} catch (HibernateException e) {
			transaction.rollback();
			e.printStackTrace();
			throw e;
		} finally {
			session.close();
		}
	}

	public static User readLogin(SessionFactory sessionFactory, String login) throws HibernateException {
		Session session = sessionFactory.openSession();
		Transaction transaction = null;
		User user = null;
		try {
			transaction = session.beginTransaction();
			user = readLogin(session, login);
			transaction.commit();
		} catch (HibernateException e) {
			transaction.rollback();
			e.printStackTrace();
			throw e;
		} finally {
			session.close();
		}
		return user;
	}

	/**
	 * @param session
	 * @param descriptorName
	 * @return the descriptor
	 * @throws HibernateException
	 */
	public static User readLogin(Session session, String login) throws HibernateException {
		String queryString = "from " + User.class.getSimpleName() + " where login =:login";
		return (User) session.createQuery(queryString).setParameter("login", login).uniqueResult();
	}

	public static List<User> search(Session session, String containedString, int filter) {
		String filername = "1";
		if (filter == User.SEARCH_NOT_ACTIVATED)
			filername = "comfirmed = 0";
		else if (filter == User.SEARCH_ONLY_ACTIVATED)
			filername = "comfirmed = 1";
		String queryString = "from " + User.class.getSimpleName()
				+ " where mail like :containedString and :filtername";
		return session.createQuery(queryString).setParameter("containedString", "%" + containedString + "%")
				.setParameter("filtername", filername).list();
	}

	public static void activate(Session session, long id) {
		User user = read(session, id);
		user.setConfirmed(true);
	}

	public static void desactivate(Session session, long id) {
		User user = read(session, id);
		user.setConfirmed(false);
	}

	public static void activateAll(Session session) {
		Query query = session
				.createQuery("update  " + User.class.getSimpleName() + " set confirmed = :confirmed ");
		// where confirmed=:notconfirmed " + "
		query.setParameter("confirmed", true);
		// query.setParameter("notconfirmed", false);
		query.executeUpdate();
	}

	public static void activate(Session session, List<Long> ids) {
		Query query = session.createQuery(
				"update  " + User.class.getSimpleName() + " set confirmed = :confirmed where id IN (:ids) ");
		// where confirmed=:notconfirmed " + "
		query.setParameter("confirmed", true);
		query.setParameterList("ids", ids);
		query.executeUpdate();
	}

	public static String renewToken(Session session, long id) {
		User user = (User) session.get(User.class, id);
		user.setToken(new BigInteger(130, new SecureRandom()).toString(32));
		session.save(user);
		return user.getToken();

	}

}