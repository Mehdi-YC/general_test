import { RequestHandler } from '@sveltejs/kit';
import prisma from '$lib/prisma';

export const get: RequestHandler = async () => {
  const students = await prisma.student.findMany();
  return {
    body: students,
  };
};

export const post: RequestHandler = async (request) => {
  const { firstName, lastName, email } = request.body;
  const student = await prisma.student.create({
    data: {
      firstName,
      lastName,
      email,
    },
  });
  return {
    status: 201,
    body: student,
  };
};

