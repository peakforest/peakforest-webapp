/**
 * 
 */
package fr.metabohub.peakforest.dao.maps;

import java.util.Date;
import java.util.List;

import org.hibernate.HibernateException;
import org.hibernate.Query;
import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.hibernate.Transaction;

import fr.metabohub.peakforest.model.maps.MapManager;

/**
 * @author Nils Paulhe
 * 
 */
@SuppressWarnings("unchecked")
public class MapManagerDao {

	/**
	 * @param sessionFactory
	 * @param mapManager
	 * @return id, the new generated id
	 * @throws HibernateException
	 */
	public static Long create(SessionFactory sessionFactory, MapManager mapManager) throws HibernateException {
		Session session = sessionFactory.openSession();
		Transaction transaction = null;
		Long id = null;
		try {
			transaction = session.beginTransaction();
			id = create(session, mapManager);
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
	public static Long create(Session session, MapManager mapManager) throws HibernateException {
		Long id;
		mapManager.setCreated(new Date());
		mapManager.setUpdated(new Date());
		id = (Long) session.save(mapManager);
		return id;
	}

	// /**
	// * @param sessionFactory
	// * @param descriptor
	// * @throws HibernateException
	// */
	// public static void update(SessionFactory sessionFactory, MapManager MapManager) throws
	// HibernateException {
	// Session session = sessionFactory.openSession();
	// Transaction transaction = null;
	// try {
	// transaction = session.beginTransaction();
	// update(session, MapManager);
	// transaction.commit();
	// } catch (HibernateException e) {
	// transaction.rollback();
	// e.printStackTrace();
	// throw e;
	// } finally {
	// session.close();
	// }
	// }

	// /**
	// * @param session
	// * @param descriptor
	// * @throws HibernateException
	// */
	// public static void update(Session session, MapManager MapManager) throws HibernateException {
	// MapManager.setUpdated(new Date());
	// session.update(MapManager);
	// }

	// /**
	// * @param sessionFactory
	// * @param id
	// * @return
	// * @throws HibernateException
	// */
	// public static MapManager read(SessionFactory sessionFactory, Long id) throws HibernateException {
	// Session session = sessionFactory.openSession();
	// Transaction transaction = null;
	// MapManager mapManager = null;
	// try {
	// transaction = session.beginTransaction();
	// mapManager = read(session, id);
	// mapManager.getMapEntities().size();
	// transaction.commit();
	// } catch (HibernateException e) {
	// transaction.rollback();
	// e.printStackTrace();
	// throw e;
	// } finally {
	// session.close();
	// }
	// return mapManager;
	// }
	//
	// public static MapManager read(Session session, Long id) {
	// MapManager MapManager;
	// MapManager = (MapManager) session.get(MapManager.class, id);
	// return MapManager;
	// }

	// public static MapManager load(Session session, Long id) {
	// return (MapManager) session.load(MapManager.class, id);
	// }

	/**
	 * @param sessionFactory
	 * @param mapSource
	 * @return the MapManager
	 * @throws HibernateException
	 */
	public static MapManager read(SessionFactory sessionFactory, Short mapSource) throws HibernateException {
		Session session = sessionFactory.openSession();
		Transaction transaction = null;
		MapManager mapManager = null;
		try {
			transaction = session.beginTransaction();
			mapManager = read(session, mapSource);
			mapManager.getMapEntities().size();
			transaction.commit();
		} catch (HibernateException e) {
			transaction.rollback();
			e.printStackTrace();
			throw e;
		} finally {
			session.close();
		}
		return mapManager;
	}

	/**
	 * @param session
	 * @param mapSource
	 * @return
	 * @throws HibernateException
	 */
	public static MapManager read(Session session, Short mapSource) throws HibernateException {
		String queryString = "from " + MapManager.class.getSimpleName() + " where map_source =:source";
		MapManager mapManager = (MapManager) session.createQuery(queryString)
				.setParameter("source", mapSource).uniqueResult();
		mapManager.getMapEntities().size();
		return mapManager;
	}

	/**
	 * @param session
	 * @param email
	 * @return
	 * @throws HibernateException
	 */
	public static boolean exists(Session session, Short mapSource) throws HibernateException {
		boolean exists = false;
		String hqlQuery = "select count(*) from " + MapManager.class.getSimpleName()
				+ " where map_source =:source";
		Query query = session.createQuery(hqlQuery);
		query.setParameter("source", mapSource);
		Object queryResult = query.uniqueResult();
		exists = queryResult != null && ((Long) queryResult).intValue() == 1;
		return exists;

	}

	/**
	 * @param session
	 * @param mapSource
	 * @return
	 * @throws HibernateException
	 */
	public static boolean exists(SessionFactory sessionFactory, Short mapSource) throws HibernateException {
		Session session = sessionFactory.openSession();
		Transaction transaction = null;
		boolean exists = false;
		try {
			transaction = session.beginTransaction();
			exists = MapManagerDao.exists(session, mapSource);
			transaction.commit();
		} catch (Exception e) {
			transaction.rollback();
			e.printStackTrace();
		} finally {
			session.close();
		}
		return exists;
	}

	public static List<MapManager> readAll(SessionFactory sessionFactory) {
		Session session = sessionFactory.openSession();
		Transaction transaction = null;
		List<MapManager> mapManagers = null;
		try {
			transaction = session.beginTransaction();
			mapManagers = MapManagerDao.readAll(session);
			transaction.commit();
		} catch (Exception e) {
			transaction.rollback();
			e.printStackTrace();
		} finally {
			session.close();
		}
		return mapManagers;
	}

	public static List<MapManager> readAll(Session session) {
		return session.createQuery("from " + MapManager.class.getSimpleName()).list();
	}

	// public static void delete(Session session, Long id) throws HibernateException {
	// MapManager mapManager = read(session, id);
	// session.delete(mapManager);
	// }

	/**
	 * @param session
	 * @param email
	 * @throws HibernateException
	 */
	public static void delete(Session session, Short mapSource) throws HibernateException {
		MapManager mapManager = read(session, mapSource);
		// session.createSQLQuery("delete from map_entity where map_manager_id=" + mapManager.getId())
		// .executeUpdate();
		session.delete(mapManager);
	}

	/**
	 * @param sessionFactory
	 * @param mapSource
	 * @throws HibernateException
	 */
	public static void delete(SessionFactory sessionFactory, Short mapSource) throws HibernateException {
		Session session = sessionFactory.openSession();
		Transaction transaction = null;
		try {
			transaction = session.beginTransaction();
			delete(session, mapSource);
			transaction.commit();
		} catch (HibernateException e) {
			transaction.rollback();
			e.printStackTrace();
			throw e;
		} finally {
			session.close();
		}
	}

	// /**
	// * @param sessionFactory
	// * @param id
	// * @throws HibernateException
	// */
	// public static void delete(SessionFactory sessionFactory, long id) throws HibernateException {
	// Session session = sessionFactory.openSession();
	// Transaction transaction = null;
	// try {
	// transaction = session.beginTransaction();
	// session.createSQLQuery("delete from map_entity where map_manager_id=" + id).executeUpdate();
	// delete(session, id);
	// transaction.commit();
	// } catch (HibernateException e) {
	// transaction.rollback();
	// e.printStackTrace();
	// throw e;
	// } finally {
	// session.close();
	// }
	// }

}