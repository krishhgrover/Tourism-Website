import React, { createContext, useContext, useState, useEffect } from 'react';
import axios from 'axios';

const AuthContext = createContext(null);

export const AuthProvider = ({ children }) => {
  const [user, setUser]       = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const token = localStorage.getItem('wl_token');
    if (token) {
      axios.defaults.headers.common['Authorization'] = `Bearer ${token}`;
      axios.get('/api/auth/profile')
        .then(({ data }) => { if (data.success) setUser(data.user); })
        .catch(() => localStorage.removeItem('wl_token'))
        .finally(() => setLoading(false));
    } else {
      setLoading(false);
    }
  }, []);

  const login = async (email, password) => {
    const { data } = await axios.post('http://localhost:5000/api/auth/login', { email, password });
    if (data.success) {
      localStorage.setItem('wl_token', data.token);
      axios.defaults.headers.common['Authorization'] = `Bearer ${data.token}`;
      setUser(data.user);
    }
    return data;
  };

  const register = async (payload) => {
    const { data } = await axios.post('http://localhost:5000/api/auth/register', payload);
    if (data.success) {
      localStorage.setItem('wl_token', data.token);
      axios.defaults.headers.common['Authorization'] = `Bearer ${data.token}`;
      setUser(data.user);
    }
    return data;
  };

  const logout = () => {
    localStorage.removeItem('wl_token');
    delete axios.defaults.headers.common['Authorization'];
    setUser(null);
  };

  const updateUser = (u) => setUser(prev => ({ ...prev, ...u }));

  return (
    <AuthContext.Provider value={{ user, loading, login, register, logout, updateUser }}>
      {children}
    </AuthContext.Provider>
  );
};

export const useAuth = () => useContext(AuthContext);
